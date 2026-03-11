import 'package:autogumi_plaza/data_manager.dart';

class SqflitePlugin {
  static Future<void> identitySQLite() async {
    DataManager.identity = Identity(
      id: 0,
      identity: '00000000000000000000000000000000',
    );
  }

  static Future<String?> lastUserNameSQLite() async {
    return null;
  }

  static Future<void> saveLastUserNameSQLite(String userName) async {
    // web: do nothing
  }

  static Future<dynamic> runLocalSelect(String sql) async {
    throw UnsupportedError('Local SQLite is not available on web.');
  }
}