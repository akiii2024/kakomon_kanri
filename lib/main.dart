import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '過去問管理（仮）',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, String>> _pastEntries = []; // 過去の入力を保存するリスト

  @override
  void initState() {
    super.initState();
    _loadPastEntries();
  }

  void _loadPastEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? entries = prefs.getStringList('pastEntries');
    if (entries != null) {
      setState(() {
        _pastEntries = entries.map((entry) {
          List<String> parts = entry.split('|');
          return {'teacherName': parts[0], 'className': parts[1]};
        }).toList();
      });
    }
  }

  void _savePastEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> entries = _pastEntries.map((entry) {
      return '${entry['teacherName']}|${entry['className']}';
    }).toList();
    await prefs.setStringList('pastEntries', entries);
  }

  void _navigateAndDisplaySelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecondPage()),
    );

    if (result != null) {
      setState(() {
        _pastEntries.add(result); // リストに結果を追加
        _savePastEntries(); // 保存
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
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1.0, color: Colors.grey),
                    ),
                  ),
                  child: ListTile(
                    title: Text('講師名：${_pastEntries[index]['teacherName']}'),
                    subtitle: Text('授業名：${_pastEntries[index]['className']}'),
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

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final TextEditingController _teacherNameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();

  @override
  void dispose() {
    _teacherNameController.dispose();
    _classController.dispose();
    super.dispose();
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
            SizedBox(height: 20), // テキストフィールドと保存ボタン間のスペースを追加
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_teacherNameController.text.isNotEmpty && _classController.text.isNotEmpty) {
                    Navigator.pop(context, {
                      'teacherName': _teacherNameController.text,
                      'className': _classController.text,
                    });
                  } else {
                    final snackBar = SnackBar(
                      content: Text('講師名と授業名の両方を入力してください。'),
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
    )
    );
  }
}

