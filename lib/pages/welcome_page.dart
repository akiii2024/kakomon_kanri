import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signUp_page.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  int currentIndex = 0;
  PageController pageController = PageController();

  final List<OnboardingContent> contents = [
    OnboardingContent(
      title: 'アプリへようこそ',
      description: 'このアプリでできることを説明していきます',
      image: 'assets/images/Question-Mark-PNG-Transparent-Image.png',
    ),
    OnboardingContent(
      title: '機能その1',
      description: 'アプリの主要な機能について説明します',
      image: 'assets/images/Question-Mark-PNG-Transparent-Image.png',
    ),
    OnboardingContent(
      title: '始めましょう',
      description: 'アカウントを作成するか、ゲストとしてログインできます',
      image: 'assets/images/Question-Mark-PNG-Transparent-Image.png',
    ),
  ];

  Future<void> guestLogin() async {
    await FirebaseAuth.instance.signInAnonymously();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: PageView.builder(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemCount: contents.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        contents[index].image,
                        height: 200,
                      ),
                      SizedBox(height: 20),
                      Text(
                        contents[index].title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        contents[index].description,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              contents.length,
              (index) => Container(
                height: 10,
                width: 10,
                margin: EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  color: currentIndex == index ? Colors.blue : Colors.grey,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            flex: 1,
            child: currentIndex == contents.length - 1
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Stack(
                      children: [
                        // ログインと新規作成ボタンを中央に配置
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context, 
                                    MaterialPageRoute(builder: (context) => LoginPage()));
                                },
                                child: Text("ログイン"),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => SignUpPage()));
                                },
                                child: Text("新規作成"),
                              ),
                            ],
                          ),
                        ),
                        // 戻るボタンを左下に配置
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: ElevatedButton(
                            onPressed: () {
                              pageController.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            },
                            child: Text("戻る"),
                          ),
                        ),
                        // ゲストログインを右下に配置
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: ElevatedButton(
                            onPressed: () async {
                              await guestLogin();
                              Navigator.push(context,
                                MaterialPageRoute(builder: (context) => MyHomePage()));
                            },
                            child: Text("アカウントなしで始める"),
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (currentIndex > 0)
                          ElevatedButton(
                            onPressed: () {
                              pageController.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            },
                            child: Text("戻る"),
                          ),
                        if (currentIndex == 0)
                          SizedBox(),
                        ElevatedButton(
                          onPressed: () {
                            pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          },
                          child: Text("次へ"),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// オンボーディングコンテンツのモデルクラス
class OnboardingContent {
  final String title;
  final String description;
  final String image;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.image,
  });
}
