import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _logoutMessage = '';

  Future<Map<String, String>> _loadProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot userProfileSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (userProfileSnapshot.docs.isNotEmpty) {
        var userProfile = userProfileSnapshot.docs.first.data() as Map<String, dynamic>;
        return {
          'email': userProfile['email'],
          'username': userProfile['username'],
          'department': userProfile['department'],
          'grade': userProfile['grade'],
        };
      }
    }
    return {};
  }

  Future<void> _updateProfile(Map<String, String> profileData) async {
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update(profileData);
  }

  Future<void> _logout() async {
    try{
      await FirebaseAuth.instance.signOut();
      _logoutMessage = 'ログアウト成功';
    } catch (e) {
      _logoutMessage = 'ログアウトに失敗しました：$e';
    }
  }

  Future<void> _showEditDialog(Map<String, String> profileData) async {
    await showDialog(
      context: context,
      builder: (context) => ProfileEditDialog(profileData: profileData),
    );
    setState(() {}); // ダイアログが閉じた後に画面をリフレッシュ
  }

  Future<void> _showEditDepartmentDialog() async {
    await showDialog(
      context: context,
      builder: (context) => ProfileEditDepartmentDialog(),
    );
    setState(() {}); // ダイアログが閉じた後に画面をリフレッシュ
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _loadProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('プロファイルが見つかりません'));
          } else {
            var profileData = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CircleAvatar(
                            radius: 30.0,
                            child: Icon(Icons.person, size: 30.0),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profileData['username'] ?? '',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(profileData['email'] ?? ''),
                          ],
                        ),
                      ],
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.school),
                      title: Text('所属学部：${profileData['department']}'),
                      subtitle: Text('学年：${profileData['grade']}回生'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('プロフィールの編集'),
                      onTap: () {
                        _showEditDialog(profileData);
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.edit_document),
                      title: Text('所属学部の編集'),
                      onTap: () {
                        _showEditDepartmentDialog();
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('ログアウト'),
                      onTap: () async {
                        await _logout();
                        if (_logoutMessage.startsWith('ログアウト成功')) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('ログアウト成功'),
                              content: Text('正常にログアウトできました。'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('OK'))
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class ProfileEditDialog extends StatefulWidget {
  final Map<String, String> profileData;

  ProfileEditDialog({required this.profileData});

  @override
  _ProfileEditDialogState createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profileData['username']);
    _emailController = TextEditingController(text: widget.profileData['email']);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('プロフィールの編集'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'ユーザー名を入力してください';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('キャンセル'),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              // Firestoreのユーザードキュメントを更新
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({
                'username': _usernameController.text,
              });

              Navigator.of(context).pop();
            }
          },
          child: Text('保存'),
        ),
      ],
    );
  }
}

class ProfileEditDepartmentDialog extends StatefulWidget {
  @override
  _ProfileEditDepartmentDialogState createState() => _ProfileEditDepartmentDialogState();
}

class _ProfileEditDepartmentDialogState extends State<ProfileEditDepartmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _departmentController;
  late TextEditingController _gradeController;

  @override
  void initState() {
    super.initState();
    _departmentController = TextEditingController();
    _gradeController = TextEditingController();
  }

  @override
  void dispose() {
    _departmentController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('所属学部の編集'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              items: [
                DropdownMenuItem(value: '1', child: Text('１回生')),
                DropdownMenuItem(value: '2', child: Text('２回生')),
                DropdownMenuItem(value: '3', child: Text('３回生')),
                DropdownMenuItem(value: '4', child: Text('４回生')),
              ],
              onChanged: (value) {
                // 選択された値を処理する
                _gradeController.text = value ?? '';
              },
              decoration: InputDecoration(labelText: '学年を選択してください'),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              items: [
                DropdownMenuItem(value: '文学部', child: Text('文学部')),
                DropdownMenuItem(value: '工学部', child: Text('工学部')),
                DropdownMenuItem(value: '経済学部', child: Text('経済学部')),
              ],
              onChanged: (value) {
                // 選択された値を処理する
                _departmentController.text = value ?? '';
              },
              decoration: InputDecoration(labelText: '学部を選択してください'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('キャンセル'),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              // Firestoreのユーザードキュメントを更新
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({
                'department': _departmentController.text,
                'grade': _gradeController.text,
              });
            }
            Navigator.of(context).pop();
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}