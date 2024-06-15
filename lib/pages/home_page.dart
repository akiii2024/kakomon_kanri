//一番最初に出てくるページです。すべてのハブとなり最初におすすめを表示する画面でもあります。
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'reg_pastques.dart';
import 'setting_page.dart';
import 'detail_page.dart';
import 'my_library_page.dart';
//import '../data/user_id.dart';
import 'login_page.dart';

const boxName = "aBox";

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, String>> _pastEntries = []; // 過去の入力を保存するリスト
  final Box box = Hive.box(boxName);
  //String userId = UserID.currentUserId;
  //String userName = UserID.currentUserName;
  String? emailAddress; // ユーザーのメールアドレス
  String? username; // ユーザー名

  @override
  void initState(){
    super.initState();
    //_loadPastEntries();
    _loadCloudFire(); 
    _initializePastEntries(); // 過去の入力を初期化
    _loadProfile(); // プロファイル情報を読み込む
  }

  // 過去の入力を初期化するメソッド
  void _initializePastEntries(){
    if(_pastEntries.isEmpty){
      _pastEntries.addAll([
        {
          'teacherName': '田中先生',
          'className': '英語',
          'imagePath': 'assets/images/en_example.jpg',
          'dataSource': 'assets',
        },
        {
          'teacherName': '山田先生',
          'className': '国語',
          'imagePath': 'assets/images/jp_example.jpg',
          'dataSource': 'assets',
        },
        {
          'teacherName': '中田先生',
          'className': '数学',
          'imagePath': 'assets/images/math_example.jpg',
          'dataSource': 'assets',
        },
      ]);
      _savePastEntries(); // 初期化したデータを保存
    }
  }

  // 過去の入力を読み込むメソッド
  void _loadPastEntries(){
    final entries = box.get('pastEntries', defaultValue: []);
    setState(() {
      _pastEntries = List<Map<String, String>>.from(
        (entries as List).map((item) => Map<String, String>.from(item))
      );
    });
  }

  // 過去の入力を保存するメソッド
  void _savePastEntries(){
    box.put('pastEntries', _pastEntries);
  }

  // 指定したインデックスの入力を削除するメソッド
  void _deleteEntry(int index){
    setState(() {
      _pastEntries.removeAt(index);
      _savePastEntries(); // 削除後のデータを保存
    });
  }

  // 新しいページに遷移し、結果を受け取るメソッド
  void _navigateAndDisplaySelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecondPage()),
    );

    if (result != null) {
      setState(() {
        _pastEntries.add(result);
        //_savePastEntries(); // リストに結果を追加
        _saveCloudFire(); // クラウドに保存
      });
    }
  }

  // 指定したインデックスの入力をタップしたときの処理
  void _onEntryTap(int index){
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailsPage(entry: _pastEntries[index])
      ),
    );
  }

  // クラウドにデータを保存するメソッド
  Future<void> _saveCloudFire() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('pastEntries').doc('pastEntriesList').set({
      'entries': _pastEntries.map((entry) => {
        'teacherName': entry['teacherName'],
        'className': entry['className'],
        'imagePath': entry['imagePath'],
        'dataSource': entry['dataSource'],
      }).toList(),
    });
  }

  // クラウドからデータを読み込むメソッド
  Future<void> _loadCloudFire() async {
    final snapshot = await FirebaseFirestore.instance.collection('pastEntries').get();

    for (var doc in snapshot.docs) {
      print(doc.data().toString());
    }

    setState(() {
      _pastEntries = snapshot.docs.expand((doc) {
        final data = doc.data();
        final entries = data['entries'] as List<dynamic>;
        return entries.map((entry) => {
          'teacherName': entry['teacherName'] as String,
          'className': entry['className'] as String,
          'imagePath': entry['imagePath'] as String,
          'dataSource': entry['dataSource'] as String,
        });
      }).toList();
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
        });
      } else{
        setState(() {
          emailAddress = user.email;
          username = 'undefined';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('あなたへのおすすめ'),
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
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("確認"),
                        content: Text("ログアウトしますか？"),
                        actions: [
                          TextButton(
                            child: Text("いいえ"),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: Text("はい"),
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                              setState((){
                                emailAddress = '';
                                username = '';
                              });
                              Navigator.of(context).pushAndRemoveUntil  (
                                MaterialPageRoute(builder: (context) => MyHomePage()),
                                (Route<dynamic> route) => false
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Icon(Icons.person),
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
                  MaterialPageRoute(builder: (context) => LibraryPage()),
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
      body: _pastEntries.isEmpty
          ? Center(child: Text('過去力はありません'))
          : Column(
        children: <Widget>[
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _loadCloudFire();
                await _loadProfile();
              },
              child: ListView.builder(
                itemCount: _pastEntries.length,
                itemBuilder: (context, index) {
                  var imagePath = _pastEntries[index]['imagePath'];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1.0, color: Colors.grey),
                      ),
                    ),
                    child: ListTile(
                      leading: imagePath != null  && imagePath.isNotEmpty
                        ?(imagePath.startsWith('assets/images/')
                          ? Image.asset(imagePath)
                          : (File(imagePath).existsSync()
                            ? Image.file(File(imagePath))
                            : Image.asset('assets/images/Question-Mark-PNG-Transparent-Image.png')))
                        : Image.asset('assets/images/Question-Mark-PNG-Transparent-Image.png'),
                      title: Text('講師名：${_pastEntries[index]['teacherName']}'),
                      subtitle: Text('授業名：${_pastEntries[index]['className']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
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
                                    child: Text("いいえ"),
                                    isDestructiveAction: false,
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  CupertinoDialogAction(
                                    child: Text("はい"),
                                    isDestructiveAction: true,
                                    onPressed: (){
                                      _deleteEntry(index);
                                      Navigator.of(context).pop();
                                    },
                                    )
                                ],
                              )
                            );
                          }
                        }
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