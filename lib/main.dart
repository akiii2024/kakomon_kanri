import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';

const boxName = "aBox";

void main() async{
  await Hive.initFlutter();
  await Hive.openBox(boxName);
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
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          title: Text("確認"),
                          content: Text("本当に削除してよろしいですか？"),
                          actions:[
                            CupertinoDialogAction(
                              child: Text("いいえ"),
                              isDestructiveAction: false,
                              onPressed: (){
                                Navigator.of(context).pop();
                              }),
                              CupertinoDialogAction(
                                child: Text("はい"),
                                isDestructiveAction: true,
                                onPressed: (){
                                  _deleteEntry(index);
                                },
                                )
                          ],
                        )
                      )
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
            SizedBox(height: 20), // テキストフィールドと保存ボタン間のスペースを追加
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_teacherNameController.text.isNotEmpty && _classController.text.isNotEmpty && _image != null) {
                    Navigator.pop(context, {
                      'teacherName': _teacherNameController.text,
                      'className': _classController.text,
                      'imagePath': _image!.path
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

