import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  String _signUpMessage = "";

  Future<void> _signUp() async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
        //displayName: _usernameController.text,
      );

    await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
      'email': _emailController.text,
      'username': _usernameController.text,
    });

    _signUpMessage = "ユーザー登録が完了しました。";

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _signUpMessage = "弱いパスワードです。";
        //print("弱いパスワードです。");
      } else if (e.code == 'email-already-in-use') {
        _signUpMessage = "すでにメールアドレスが使用されています。";
        //print("すでにメールアドレスが使用されています。");
      }
    } catch (e) {
      _signUpMessage = "エラー: $e";
      //print("エラー: $e");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新規作成'),
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
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'ユーザー名'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final errors = {
                  'メールアドレス、パスワード、ユーザー名を入力してください。': _emailController.text.isEmpty && _passwordController.text.isEmpty && _usernameController.text.isEmpty,
                  'メールアドレスとパスワードを入力してください。': _emailController.text.isEmpty && _passwordController.text.isEmpty,
                  'メールアドレスとユーザー名を入力してください。': _emailController.text.isEmpty && _usernameController.text.isEmpty,
                  'パスワードとユーザー名を入力してください。': _passwordController.text.isEmpty && _usernameController.text.isEmpty,
                  'メールアドレスを入力してください。': _emailController.text.isEmpty,
                  'パスワードを入力してください。': _passwordController.text.isEmpty,
                  'ユーザー名を入力してください。': _usernameController.text.isEmpty,
                };
                for (var error in errors.entries) {
                  if (error.value) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('エラー'),
                          content: Text(error.key),
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
                    return;
                  }
                }

                await _signUp();

                if (_signUpMessage == "ユーザー登録が完了しました。") {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('登録完了'),
                        content: Text('ユーザー登録が完了しました。'),
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
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('エラー'),
                        content: Text(_signUpMessage),
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
              },
              child: Text('新規作成'),
            ),
          ],
        ),
      ),
    );
  }
}
