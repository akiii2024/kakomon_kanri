import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('オプション1が選択されました'),
                ),
              );
              //MaterialPageRoute(builder: (context) => DeviceAndPackageInfoSampleScreen()),

              //);
            },
          ),
          ListTile(
            title: Text('オプション2（未実装）'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('オプション2が選択されました'),
                ),
              );
              // オプション2の処理
            },
          ),
          ListTile(
            title: Text('オプション3（未実装）'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('オプション3が選択されました'),
                ),
              );
              // オプション3の処理
            },
          ),
        ],
      ),
    );
  }
}
