import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';


class ImageViewPage extends StatelessWidget{
  final Map<String, dynamic> entry;
  ImageViewPage({required this.entry});
  @override
  Widget build(BuildContext context){
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // ステータスバーを透明に設定
      statusBarIconBrightness: Brightness.dark // アイコンの明るさを設定

      
    ));

    return Scaffold(

      body: Center(
        child: InteractiveViewer(
          child: Image.file(File(entry['imagePath']!)),
        ),

      ),
    );
  }


}
