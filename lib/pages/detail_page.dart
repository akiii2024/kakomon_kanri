//home_pageやmy_libraryで項目をタップした際に表示されるページです。
//現在my_libraryから参照するとindexがずれるため要修正
import 'package:flutter/material.dart';
import 'dart:io';
import 'image_viewer_page.dart';

class DetailsPage extends StatelessWidget {

  final Map<String, String> entry;

  DetailsPage({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('詳細ページ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry['imagePath'] != null) 
              GestureDetector(
                onTap: () {
                  if(entry['imagePath']!.startsWith('assets/images/')){
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return ImageViewPage(entry: {'imagePath': entry['imagePath']!});
                    }));
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('画像が見つかりませんでした。'),
                    ));
                  }
                },
                child: entry['imagePath']?.startsWith('assets/images/') == true
                  ? Image.asset(entry['imagePath']!)
                  : (File(entry['imagePath']!).existsSync()
                      ? Image.file(File(entry['imagePath']!))
                      : Image.asset('assets/images/Question-Mark-PNG-Transparent-Image.png')),
              ),
            SizedBox(height: 10),
            Text('講師名：${entry['teacherName']}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('授業名：${entry['className']}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('コメント：${entry['comment']}', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}

