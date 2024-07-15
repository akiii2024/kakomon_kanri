//過去問の登録ページです
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final TextEditingController _teacherNameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final Uuid uuid = Uuid();
  XFile? _image;
  final List<Map<String, dynamic>> _pastEntries = []; // ここに追加
  String? _userEmail;
  String? _userDepartment;
  String? _userGrade;

  Future<Map<String, String>> _loadProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot userProfileSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (userProfileSnapshot.docs.isNotEmpty) {
        var userProfile = userProfileSnapshot.docs.first.data() as Map<String, dynamic>;
        return {
          'email': userProfile['email'],
          'username': userProfile['username'],
          'department': userProfile['department'],
          'grade': userProfile['grade'],
        };
      }
    }
    return {};
  }

  @override
  void initState() {
    super.initState();
    _loadProfile().then((profile) {
      setState(() {
        _userEmail = profile['email'];
        _userDepartment = profile['department'];
        _userGrade = profile['grade'];
      });
    });
  }

  @override
  void dispose() {
    _teacherNameController.dispose();
    _classController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState((){
          _image = pickedFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('画像の選択に失敗しました。'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pickImageCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState((){
          _image = pickedFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('画像の選択に失敗しました。'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _savePastEntry() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    _pastEntries.add({
      'id': uuid.v4(),
      'teacherName': _teacherNameController.text,
      'className': _classController.text,
      'comment': _commentController.text,
      'imagePath': _image!.path,
      'dataSource': 'user',
      'userEmail': _userEmail, // 追加
      'userDepartment': _userDepartment, // 追加
      'userGrade': _userGrade, // 追加
    });
    await firestore.collection('pastEntries').doc('pastEntriesList').set({
      'entries': _pastEntries,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('過去問の登録'),
      ),
      body: SingleChildScrollView(
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Text('過去問を登録してください'),
            ),
            SizedBox(height: 20), // 最初のテキストと入力フィールド間のスペースを追加
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('画像を選択'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickImageCamera,
                    child: Text('カメラで撮影'),
                  ),
                ],
              ),
            ),
            if (_image != null)
              Image.file(File(_image!.path)),
            SizedBox(height: 20), // 最初のテキストと入力フィールド間のスペース追加
            Text('講師の名前'),
            TextField(
              controller: _teacherNameController,
              decoration: InputDecoration(
                labelText: '講師名を入力してください',//プルダウンメニュー置き換え予定
                hintText: '講師名',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20), // テキストフィールド間のスペースを追加
            Text('授業のタイトル'),
            TextField(
              controller: _classController,
              decoration: InputDecoration(
                labelText: '授業名を入力してください',//プルダウンメニュー置き換え予定
                hintText: '授業名',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20), // テキストフィルドと保存ボタン間のスペースを追加
            Text('コメント'),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'コメントを入力してください',
                hintText: 'コメント',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_teacherNameController.text.isNotEmpty && _classController.text.isNotEmpty && _image != null) {
                    Navigator.pop(context, {
                      'id': uuid.v4(),
                      'teacherName': _teacherNameController.text,
                      'className': _classController.text,
                      'comment': _commentController.text,
                      'imagePath': _image!.path,
                      'dataSource': 'user',
                      'userEmail': _userEmail,
                      'userDepartment': _userDepartment,
                      'userGrade': _userGrade,
                    });
                  } else {
                    final snackBar = SnackBar(
                      content: Text('講師名、授業名、コメント、画像のすべてを入力してください。'),
                      duration: Duration(seconds: 2),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: Text('保存'),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}