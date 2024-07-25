//home_pageやmy_libraryで項目をタップした際に表示されるページです。
//現在my_libraryから参照するとindexがずれるため要修正
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'image_viewer_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 追加

class DetailsPage extends StatefulWidget {
  final Map<String, String> entry;

  DetailsPage({required this.entry});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double? rating;
  String? emailAddress;
  String? username;
  String? userDepartment;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadRating();
  }

  Future<void> _loadProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot userProfileSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (userProfileSnapshot.docs.isNotEmpty) {
        var userProfile = userProfileSnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          emailAddress = userProfile['email'];
          username = userProfile['username'];
          userDepartment = userProfile['department']; // 学部情報を取得
          profileImageUrl = userProfile['profileImageUrl']; // プロフィール画像のURLを取得
        });
      } else {
        setState(() {
          emailAddress = user.email;
          username = 'undefined';
          userDepartment = 'undefined'; // 学部情報がない場合のデフォルト値
        });
      }
    }
  }

  Future<void> _loadRating() async {
    QuerySnapshot ratingSnapshot = await _firestore.collection('ratings').where('entryId', isEqualTo: widget.entry['userEmail']).get();
    if (ratingSnapshot.docs.isNotEmpty) {
      setState(() {
        rating = double.tryParse((ratingSnapshot.docs.first.data() as Map<String, dynamic>)['rating'].toString()); // 型変換を追加
      });
    }
  }

  Future<void> _saveRating(String rating) async {
    final entryId = widget.entry['userEmail'];
    final ratingRef = _firestore.collection('ratings').doc(entryId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ratingRef);

      if (snapshot.exists) {
        final currentGoodCount = snapshot.data()?['goodCount'] ?? 0;
        final newGoodCount = rating == 'good' ? currentGoodCount + 1 : currentGoodCount;
        transaction.update(ratingRef, {'goodCount': newGoodCount});
      } else {
        transaction.set(ratingRef, {
          'entryId': entryId,
          'goodCount': rating == 'good' ? 1 : 0,
          'badCount': rating == 'bad' ? 1 : 0,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('詳細ページ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.entry['imagePath'] != null) 
              GestureDetector(
                onTap: () {
                  if(widget.entry['imagePath']!.startsWith('assets/images/')){
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return ImageViewPage(entry: {'imagePath': widget.entry['imagePath']!});
                    }));
                  }else if(widget.entry['imagePath']!.startsWith('http')){
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return ImageViewPage(entry: {'imagePath': widget.entry['imagePath']!});
                    }));
                  }else if(File(widget.entry['imagePath']!).existsSync()){
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return ImageViewPage(entry: {'imagePath': widget.entry['imagePath']!});
                    }));
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('画像が見つかりませんでした。'),
                    ));
                  }
                },
                child: widget.entry['imagePath']?.startsWith('assets/images/') == true
                  ? Image.asset(widget.entry['imagePath']!)
                  : (File(widget.entry['imagePath']!).existsSync()
                      ? Image.file(File(widget.entry['imagePath']!))
                      : (Uri.tryParse(widget.entry['imagePath']!)?.isAbsolute == true
                          ? Image.network(widget.entry['imagePath']!)
                          : Image.asset('assets/images/Question-Mark-PNG-Transparent-Image.png'))),
              ),
            SizedBox(height: 10),
            Text('講師名：${widget.entry['teacherName']}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('授業名：${widget.entry['className']}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('コメント：${widget.entry['comment']}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('ユーザーメール：${widget.entry['userEmail']}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('学部：${widget.entry['userDepartment']}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('学年：${widget.entry['userGrade']}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up),
                  onPressed: () async {
                    await _saveRating('good');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('高評価しました。'),
                    ));
                  },
                ),
                IconButton(
                  icon: Icon(Icons.thumb_down),
                  onPressed: () async {
                    await _saveRating('bad');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('低評価しました。'),
                    ));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}