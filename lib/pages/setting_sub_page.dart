//受講中の科目を設定できる画面です
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

const boxName2 = 'subject_box';

class SettingSubPage extends StatefulWidget {
  @override
  _SettingSubPageState createState() => _SettingSubPageState();
}

class _SettingSubPageState extends State<SettingSubPage> {
  final box = Hive.box(boxName2);
  bool checkboxValueJP = true;
  bool checkboxValueEN = true;
  bool checkboxValueMATH = true;
  bool checkboxValueSCI = true;

  @override
  void initState(){
    super.initState();
    checkboxValueJP = box.get('jp', defaultValue: true);
    checkboxValueEN = box.get('en', defaultValue: true);
    checkboxValueMATH = box.get('math', defaultValue: true);
    checkboxValueSCI = box.get('sci', defaultValue: true);
  }

  void _saveSubject(){
    box.put('jp', checkboxValueJP);
    box.put('en', checkboxValueEN);
    box.put('math', checkboxValueMATH);
    box.put('sci', checkboxValueSCI);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('科目の選択'),
      ),
      body: Column(
        children: [
          CheckboxListTile(
            value: checkboxValueJP,
            onChanged: (bool? value){
              setState((){
                checkboxValueJP = value!;
                _saveSubject();
              });
            },
            title: Text('国語'),
          ),
          CheckboxListTile(
            value: checkboxValueEN,
            onChanged: (bool? value){
              setState((){
                checkboxValueEN = value!;
                _saveSubject();
              });
            },
            title: Text('英語'),
          ),
          CheckboxListTile(
            value: checkboxValueMATH,
            onChanged: (bool? value){
              setState((){
                checkboxValueMATH = value!;
                _saveSubject();
              });
            },
            title: Text('数学'),
          ),
          CheckboxListTile(
            value: checkboxValueSCI,
            onChanged: (bool? value){
              setState((){
                checkboxValueSCI = value!;
                _saveSubject();
              });
            },
            title: Text('理科'),
          ),
          ElevatedButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text('保存'),
          )
        ],
      ),
    );
  }
}
