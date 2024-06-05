import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'components/home_page.dart';
import 'components/setting_sub_page.dart';



void main() async{
  await Hive.initFlutter();
  await Hive.openBox(boxName);
  await Hive.openBox(boxName2);
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
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}