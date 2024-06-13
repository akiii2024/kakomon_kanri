import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signUp_page.dart';
import 'home_page.dart';
  
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _loginMessage = "";

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // ログイン成功時の処理
      _loginMessage = "ログイン成功: ${userCredential.user?.email}";
      //print(_loginMessage);
    } on FirebaseAuthException catch (e) {
      // エラーハンドリング
      _loginMessage = "ログイン失敗: $e";
      //print(_loginMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ログイン'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'メールアドレス'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'パスワード'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_emailController.text.isEmpty && _passwordController.text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('ログイン失敗'),
                        content: Text('メールアドレスとパスワードを入力してください。'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('閉じる'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    }
                  );
                } else if (_emailController.text.isEmpty && _passwordController.text.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('ログイン失敗'),
                        content: Text('メールアドレスを入力してください。'),
                      );
                    },
                  );
                } else if (_emailController.text.isNotEmpty && _passwordController.text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('ログイン失敗'),
                        content: Text('パスワードを入力してください。'),
                      );
                    },
                  );
                } else {
                  await _login();
                  if (_loginMessage.startsWith("ログイン成功")) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('ログイン成功'),
                          content: Text('ログインに成功しました。'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('閉じる'),
                              onPressed: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => MyHomePage()),
                                  (Route<dynamic> route) => false,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }else{
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('ログイン失敗'),
                          content: Text(_loginMessage),
                          actions: <Widget>[
                            TextButton(
                              child: Text('閉じる'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
              child: Text('ログイン'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: Text('新規作成'),
            ),
          ],
        ),
      ),
    );
  }
}
