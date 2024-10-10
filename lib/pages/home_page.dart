//一番最初に出てくるページです。すべてのハブとなり最初におすすめを表示する画面でもあります。
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'reg_pastques.dart';
import 'setting_page.dart';
import 'detail_page.dart';
import 'my_library_page.dart';
//import '../data/user_id.dart';
import 'login_page.dart';
import 'profile_page.dart';

const boxName = "aBox";

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, String>> _pastEntries = []; // 過去の入力を保存するリスト
  List<Map<String, String>> _filteredEntries = []; // フィルタリングされたリスト
  final Box box = Hive.box(boxName);
  final Uuid uuid = Uuid();
  String? emailAddress; // ユーザーのメールアドレス
  String? username; // ユーザー名
  String? loginState; // ログイン状態
  String? userDepartment; // ユーザーの学部情報を保存する変数
  String? profileImageUrl; // プロフィール画像のURLを保存する変数
  String _searchQuery = ''; // 検索クエリを保存する変数

  @override
  void initState(){
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadProfile();
    await _loadCloudFire();
    await _checkLoginState();
  }

  // 新しいページに遷移し、結果を受け取るメソッド
  void _navigateAndDisplaySelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecondPage()),
    );

    if (result != null) {
      String imageUrl = '';
      if (result['imagePath'] != null && result['imagePath'].isNotEmpty) {
        File imageFile = File(result['imagePath']);
        imageUrl = await _uploadImage(imageFile);
      }

      setState(() {
        _pastEntries.add({
          ...result,
          'imagePath': imageUrl,
          'dataSource': 'cloud',
        });
        _saveCloudFire();
      });
    }
  }

  // 指定したインデックスの入力をタップしたときの処理
  void _onEntryTap(int index){
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailsPage(entry: _filteredEntries[index])
      ),
    );
  }

  // クラウドにデータを保存するメソッド
  Future<void> _saveCloudFire() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('pastEntries').doc('pastEntriesList').get();
    List<Map<String, String>> existingEntries = [];

    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null && data['entries'] != null) {
        existingEntries = List<Map<String, String>>.from(
          (data['entries'] as List).map((item) => Map<String, String>.from(item))
        );
      }
    }

    // 新しいデータと既存のデータをマージ
    existingEntries.addAll(_pastEntries);

    await firestore.collection('pastEntries').doc('pastEntriesList').set({
      'entries': existingEntries.map((entry) => {
        'id': entry['id'],
        'teacherName': entry['teacherName'],
        'className': entry['className'],
        'imagePath': entry['imagePath'],
        'dataSource': entry['dataSource'],
        'userEmail': entry['userEmail'],
        'userDepartment': entry['userDepartment'],
        'userGrade': entry['userGrade'],
      }).toList()
    }, SetOptions(merge: true)); // 既存のデータにマージ
  }

  // クラウドからデータを読み込むメソッド
  Future<void> _loadCloudFire() async {
    final snapshot = await FirebaseFirestore.instance.collection('pastEntries').get();

    setState(() {
      _pastEntries = snapshot.docs.expand((doc) {
        final data = doc.data();
        final entries = data['entries'] as List<dynamic>;
        return entries.map((entry) => {
          'id': entry['id'] as String? ?? '',
          'teacherName': entry['teacherName'] as String? ?? '',
          'className': entry['className'] as String? ?? '',
          'comment': entry['comment'] as String? ?? '',
          'imagePath': entry['imagePath'] as String? ?? '',
          'dataSource': entry['dataSource'] as String? ?? '',
          'userDepartment': entry['userDepartment'] as String? ?? '', // 学部情報を取得
        });
      }).toList();

      // フィルタリング
      if(userDepartment != null && userDepartment!.isNotEmpty){
      _filteredEntries = _pastEntries.where((entry) {
        return entry['userDepartment'] == userDepartment;
        }).toList();
      }else{
        _filteredEntries = _pastEntries;
      }
    });
  }

  // プロファイル情報を読み込むメソッド
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
      } else{
        setState(() {
          emailAddress = user.email;
          username = 'undefined';
          userDepartment = 'undefined'; // 学部情報がない場合のデフォルト値
        });
      }
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      Reference ref = storage.ref().child('images/$fileName');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('画像のアップロードエラー: $e');
      return '';
    }
  }

  String? _getEntryId(int index) {
    if (index >= 0 && index < _pastEntries.length) {
      return _pastEntries[index]['id'];
    }
    return null; // インデックスが範囲外の場合はnullを返す
  }

  Future <void> _saveMyLibrary(int index) async {
    String? entryId = _getEntryId(index);
    if(entryId != null){
      await FirebaseFirestore.instance.collection('myLibrary').doc(emailAddress).update({
        'entries': FieldValue.arrayUnion([
        {
        'id': entryId,
        'teacherName': _pastEntries[index]['teacherName'],
        'className': _pastEntries[index]['className'],
        'imagePath': _pastEntries[index]['imagePath'],
        'dataSource': _pastEntries[index]['dataSource'],
      }
      ]),
      });
    }
  }

  Future<void> _checkLoginState() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      loginState = (user != null) ? 'login' : 'notLogin';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('あなたへのおすすめ'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(_pastEntries), // 全体から検索
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(username ?? ''),
              accountEmail: Text(emailAddress ?? ''),
              currentAccountPicture: GestureDetector(
                onTap: (){  
              if (emailAddress == null || emailAddress!.isEmpty) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              }
              },
              child: CircleAvatar(
                backgroundImage: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                                ? NetworkImage(profileImageUrl!)
                                : null,
                child: (profileImageUrl == null || profileImageUrl!.isEmpty)
                    ? Icon(Icons.person, size: 30.0)
                    : null,
              ),
            ),
            ),
            ListTile(
              title: Text('Main Page'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text('保存した過去問'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => LibraryPage(emailAddress: emailAddress ?? '')),
                );
              },

            ),
            ListTile(
              title: Text('設定'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SettingPage()),
                );
              },
            ),
          ]
        )
      ),
      body: _filteredEntries.isEmpty
          ? Center(child: Text('過去問はありません'))
          : Column(
        children: <Widget>[
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _loadCloudFire();
                await _loadProfile();
              },
              child: ListView.builder(
                itemCount: _filteredEntries.length,
                itemBuilder: (context, index) {
                  var sortedEntries = List.from(_filteredEntries);
                  sortedEntries.sort((a, b) => a['teacherName'].compareTo(b['teacherName']));
                  var imagePath = sortedEntries[index]['imagePath'];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1.0, color: Colors.grey),
                      ),
                    ),
                    child: ListTile(
                      leading: imagePath != null && imagePath.isNotEmpty
                        ? (imagePath.startsWith('http')
                          ? Image.network(imagePath)
                          : (imagePath.startsWith('assets/')
                            ? Image.asset(imagePath)
                            : (File(imagePath).existsSync()
                              ? Image.file(File(imagePath))
                              : Image.asset('assets/images/Question-Mark-PNG-Transparent-Image.png'))))
                        : Image.asset('assets/images/Question-Mark-PNG-Transparent-Image.png'),
                      title: Text('授業名：${sortedEntries[index]['className']}'), // 授業名を上に
                      subtitle: Text('講師名：${sortedEntries[index]['teacherName']}'), // 講師名を下に
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          if(loginState == 'login'){
                            _saveMyLibrary(index);
                          }else{
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("ログインが必要です"),
                                content: Text("この機能を使用するにはログインしてください。"),
                                actions: [
                                  TextButton(
                                    child: Text("OK"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                          }
                        },
                      ),
                      onTap: () => _onEntryTap(index),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndDisplaySelection(context),
        tooltip: '過去問の追加',
        child: Icon(Icons.add),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Map<String, String>> entries;

  CustomSearchDelegate(this.entries);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = entries.where((entry) {
      return entry['teacherName']!.toLowerCase().contains(query.toLowerCase()) ||
             entry['className']!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        var imagePath = results[index]['imagePath'];
        return ListTile(
          leading: imagePath != null && imagePath.isNotEmpty
            ? (imagePath.startsWith('http')
              ? Image.network(imagePath)
              : (imagePath.startsWith('assets/')
                ? Image.asset(imagePath)
                : (File(imagePath).existsSync()
                  ? Image.file(File(imagePath))
                  : Image.asset('assets/images/Question-Mark-PNG-Transparent-Image.png'))))
            : Image.asset('assets/images/Question-Mark-PNG-Transparent-Image.png'),
          title: Text('授業名：${results[index]['className']}'),
          subtitle: Text('講師名：${results[index]['teacherName']}'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DetailsPage(entry: results[index]),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = entries.where((entry) {
      return entry['teacherName']!.toLowerCase().contains(query.toLowerCase()) ||
             entry['className']!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        var imagePath = suggestions[index]['imagePath'];
        return ListTile(
          leading: imagePath != null && imagePath.isNotEmpty
            ? (imagePath.startsWith('http')
              ? Image.network(imagePath)
              : (imagePath.startsWith('assets/')
                ? Image.asset(imagePath)
                : (File(imagePath).existsSync()
                  ? Image.file(File(imagePath))
                  : Image.asset('assets/images/Question-Mark-PNG-Transparent-Image.png'))))
            : Image.asset('assets/images/Question-Mark-PNG-Transparent-Image.png'),
          title: Text('授業名：${suggestions[index]['className']}'),
          subtitle: Text('講師名：${suggestions[index]['teacherName']}'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DetailsPage(entry: suggestions[index]),
              ),
            );
          },
        );
      },
    );
  }
}