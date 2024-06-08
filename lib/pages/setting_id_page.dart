//ユーザーidとユーザー名を設定できる画面です。（機能しません）
import 'package:flutter/material.dart';

class SettingIdPage extends StatefulWidget {
  @override
  _SettingIdPageState createState() => _SettingIdPageState();
}

class _SettingIdPageState extends State<SettingIdPage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();

  @override
  void dispose() {
    _userNameController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IDとユーザー名の設定'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'ユーザー名を入力してください',
              hintText: 'ユーザー名',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              labelText: 'IDを入力してください',
              hintText: 'ID',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text('設定する'),
          ),
        ],
      ),
    );
  }
}

