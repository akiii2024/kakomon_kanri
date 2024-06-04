import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final TextEditingController _teacherNameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

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
            SizedBox(height: 20), // 最初のテキストと入力フィールド間のスペースを追加
            Text('講師の名前'),
            TextField(
              controller: _teacherNameController,
              decoration: InputDecoration(
                labelText: '講師名を入力してください（プルダウンメニュー置き換え予定）',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20), // テキストフィールド間のスペースを追加
            Text('授業のタイトル'),
            TextField(
              controller: _classController,
              decoration: InputDecoration(
                labelText: '授業名を入力してください（同じく置き換える予定）',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20), // テキストフィ���ルドと保存ボタン間のスペースを追加
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_teacherNameController.text.isNotEmpty && _classController.text.isNotEmpty && _image != null) {
                    Navigator.pop(context, {
                      'teacherName': _teacherNameController.text,
                      'className': _classController.text,
                      'imagePath': _image!.path,
                      'dataSource': 'user',
                    });
                  } else {
                    final snackBar = SnackBar(
                      content: Text('講師名、授業名、画像のすべてを入力してください。'),
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