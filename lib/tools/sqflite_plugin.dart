import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:autogumi_plaza/data_manager.dart';
import 'package:autogumi_plaza/global.dart';

class SqflitePlugin {
  static Database? _prefsDb;
  static Database? _exprDb;
  static final Map<String, dynamic> _exprCache = {};

  static Future<void> identitySQLite() async {
    final database = openDatabase(
      p.join(await getDatabasesPath(), 'unique_identity.db'),
      onCreate: (db, version) => db.execute(Global.sqlCreateTableIdentity),
      version: 1,
    );

    final db = await database;
    List<Map<String, dynamic>> result = await db.query('identityTable');

    if (result.isEmpty) {
      DataManager.identity = Identity.generate();
      await db.insert(
        'identityTable',
        DataManager.identity!.toMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      result = await db.query('identityTable');
    }

    DataManager.identity = Identity(
      id: 0,
      identity: result[0]['identity'].toString(),
    );
  }

  static Future<Database> _getPrefsDb() async {
    _prefsDb ??= await openDatabase(
      p.join(await getDatabasesPath(), 'prefs.db'),
      onCreate: (db, version) async {
        await db.execute(Global.sqlCreateTableIdentity);
        await db.execute(Global.sqlCreateTableLastUser);
      },
      version: 1,
    );
    return _prefsDb!;
  }

  static Future<String?> lastUserNameSQLite() async {
    final db = await _getPrefsDb();
    final rows = await db.query('lastUserTable', limit: 1);

    if (rows.isEmpty) return null;

    final v = rows[0]['userName']?.toString();
    if (v == null || v.trim().isEmpty) return null;
    return v;
  }

  static Future<void> saveLastUserNameSQLite(String userName) async {
    final db = await _getPrefsDb();
    await db.insert(
      'lastUserTable',
      {'id': 0, 'userName': userName.trim()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Database> _getExprDb() async {
    _exprDb ??= await openDatabase(inMemoryDatabasePath);
    return _exprDb!;
  }

  static String _cacheKeyLocal(String sql) => 'local::$sql';

  static String? _extractAlias(String sql) {
    final re = RegExp(
      r'^\s*SELECT\s+(.+?)\s+AS\s+([A-Za-z_][A-Za-z0-9_]*)\s*;?\s*$',
      caseSensitive: false,
      dotAll: true,
    );
    final m = re.firstMatch(sql.trim());
    if (m == null) return null;
    return m.group(2);
  }

  static Future<dynamic> runLocalSelect(String sql) async {
    final key = _cacheKeyLocal(sql);

    if (_exprCache.containsKey(key)) {
      return List<Map<String, Object?>>.from(
        (_exprCache[key] as List).map((e) => Map<String, Object?>.from(e)),
      );
    }

    final db = await _getExprDb();
    final rows = await db.rawQuery(sql);
    final alias = _extractAlias(sql);

    final normalized = rows.map((row) {
      if (row.length == 1) {
        final rawKey = row.keys.first;
        final val = row.values.first.toString();

        if (alias != null) return {alias: val};
        if (rawKey.toLowerCase() == 'id') return {'id': val};
        return {'': val};
      }
      return row;
    }).toList();

    _exprCache[key] = normalized;

    return List<Map<String, Object?>>.from(
      normalized.map((e) => Map<String, Object?>.from(e)),
    );
  }
}