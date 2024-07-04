//自分で保存した過去問が参照できるページです。
//おすすめ欄から好みの過去問も保存し、このページに表示できるようにする予定です。
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'home_page.dart';
import 'dart:io';
import 'reg_pastques.dart';

import 'detail_page.dart';

const boxName = "aBox";

class LibraryPage extends StatefulWidget {
  final String emailAddress;
  LibraryPage({required this.emailAddress});

  @override
  _LibraryPageState createState() => _LibraryPageState();

}

class _LibraryPageState extends State<LibraryPage> {
  List<Map<String, String>> _pastEntries = []; // 過去の入力を保存するリスト
  final Box box = Hive.box(boxName);
  String username = '';


  @override
  void initState(){
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadProfile();
    await _loadCloudFire();
  }

  void _loadPastEntries(){
    final entries = box.get('pastEntries', defaultValue: []);
    setState((){
      _pastEntries = List<Map<String, String>>.from(
        (entries as List).map((item) => Map<String, String>.from(item))
    );
    });
  }

  void _savePastEntries(){
    box.put('pastEntries', _pastEntries);
  }

  void _deleteEntry(int index){
    setState(() {
      _pastEntries.removeAt(index);
      _savePastEntries();
    });
  }

  void _navigateAndDisplaySelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecondPage()),
    );

    if (result != null) {
      setState(() {
        _pastEntries.add(result);
        _savePastEntries(); // リストに結果を追加
      });
    }
  }

  void _onEntryTap(int index){
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailsPage(entry: _pastEntries[index])),
    );
  }

  Future<void> _loadCloudFire() async {
    final snapshot = await FirebaseFirestore.instance.collection('myLibrary').doc(widget.emailAddress).get();

    final data = snapshot.data();
    if (data != null && data['entries'] != null) {
      setState(() {
        _pastEntries = (data['entries'] as List).map((entry) => {
          'id': entry['id'] as String? ?? '',
          'teacherName': entry['teacherName'] as String? ?? '',
          'className': entry['className'] as String? ?? '',
          'comment': entry['comment'] as String? ?? '',
          'imagePath': entry['imagePath'] as String? ?? '',
          'dataSource': entry['dataSource'] as String? ?? '',
        }).toList();
      });
    }
  }

  // プロファイル情報を読み込むメソッド
  Future<void> _loadProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot userProfileSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.emailAddress)
          .limit(1)
          .get();

      if (userProfileSnapshot.docs.isNotEmpty) {
        var userProfile = userProfileSnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          username = userProfile['username'];
        });
      } else{
        setState(() {
          username = 'undefined';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> userEntries = List<Map<String, String>>.from(_pastEntries);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('$usernameさんの保存した過去問'),
      ),
      body: userEntries.isEmpty
          ? Center(child: Text('保存した過去問はありません'))
          : Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: userEntries.length, // 修正: _pastEntries.lengthからuserEntries.lengthに変更
               itemBuilder: (context, index) {
                var imagePath = userEntries[index]['imagePath'];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1.0, color: Colors.grey),
                    ),
                  ),
                  child: ListTile(
                    leading: imagePath != null
                      ? Image.network(imagePath) // 修正: Image.fileからImage.networkに変更
                      : null,
                    title: Text('講師名: ${userEntries[index]["teacherName"]}'),
                    subtitle: Text('授業名: ${userEntries[index]["className"]}'),
                    trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: (() {
                      if(Platform.isAndroid){
                          showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text("確認"),
                          content: Text("本当に削除してよろしいですか？"),
                          actions:[
                            TextButton(
                              child: Text("いいえ"),
                              onPressed: (){
                                Navigator.of(context).pop();
                              }),
                              TextButton(
                                child: Text("はい"),
                                onPressed: (){
                                  _deleteEntry(index);
                                  Navigator.of(context).pop();
                                },
                                )
                          ],
                        )
                      );
                        }else{
                          showDialog(
                            context: context,
                             builder: (_) => CupertinoAlertDialog(
                              title: Text("確認"),
                              content: Text("本当に削除してよろしいですか？"),
                              actions: [
                                CupertinoDialogAction(
                                  isDestructiveAction: false,
                                  onPressed: (){
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("いいえ"),
                                ),
                                CupertinoDialogAction(
                                  isDestructiveAction: true,
                                  onPressed: (){
                                    _deleteEntry(index);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("はい"),
                                  )
                              ],
                            )
                          );
                        }
                      }
                    ),
                    ),
                    onTap: () => _onEntryTap(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}