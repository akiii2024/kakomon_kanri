//設定のメイン画面です。
import 'package:flutter/material.dart';
import 'setting_sub_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'setting_id_page.dart';



class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('設定'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('履修科目の登録'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingSubPage()),
              );
            },
          ),
          ListTile(
            title: Text('データの初期化'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
            Hive.box('aBox').clear().then((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('データが削除されました'),
                ),
              );
            }).catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('データ削除中にエラーが発生しました: $error'),
                ),
              );
            });
            },
          ),
          ListTile(
            title: Text('オプション3（未実装）'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingIdPage()),
                );
              },
            ),
        ],
      ),
    );
  }
}

