import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'second_page.dart';

const boxName = "aBox";

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, String>> _pastEntries = []; // 過去の入力を保存するリスト
  final Box box = Hive.box(boxName);

  @override
  void initState(){
    super.initState();
    _loadPastEntries();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
      ),
      body: _pastEntries.isEmpty
          ? Center(child: Text('過去の入力はありません'))
          : Column(
        children: <Widget>[
          Expanded(
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
                    leading: imagePath != null
                      ? Image.file(File(imagePath))
                      : null,
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
                  ),
                );
              },
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