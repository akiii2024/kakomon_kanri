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
            title: Text('オプション１'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              //Navigator.push(
                //context,
                //MaterialPageRoute(builder: (context) => DeviceAndPackageInfoSampleScreen()),
              //);
            },
          ),
          ListTile(
            title: Text('オプション2'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // オプション2の処理
            },
          ),
          ListTile(
            title: Text('オプション3'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // オプション3の処理
            },
          ),
        ],
      ),
    );
  }
}
