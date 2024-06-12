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

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print("弱いパスワードです。");
      } else if (e.code == 'email-already-in-use') {
        print("すでにメールアドレスが使用されています。");
      }
    } catch (e) {
      print("エラー: $e");
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
                await _signUp();
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
              },
              child: Text('新規作成'),
            ),
          ],
        ),
      ),
    );
  }
}
