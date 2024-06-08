//ユーザーidとパスワードを保持するクラス
//hiveを使用しデータを書き換え、保存できるように変更予定です。
import 'package:hive_flutter/hive_flutter.dart';


class UserID {
  static String currentUserName = "UserName_default";
  static String currentUserId = "UserId_default";
}
