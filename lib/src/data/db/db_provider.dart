import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'search_history_dao.dart';

class DBProvider {
  static Database _db;

  static Future<Database> open({String dbName = 'titan_app.db'}) async {
    if (_db != null && _db.isOpen) {
      return _db;
    }
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, dbName);
    print(path);
    _db = await openDatabase(path, version: 1, singleInstance: true, onCreate: (Database db, int version) async {
      await db.execute('''
create table ${SearchHistoryDao.kTable} (
  ${SearchHistoryDao.kColumnId} integer primary key autoincrement, 
  ${SearchHistoryDao.kColumnSearchText} text not null unique,
  ${SearchHistoryDao.kColumnType} text,
  ${SearchHistoryDao.kColumnTime} integer)
''');
    });
    return _db;
  }

  static Future<void> deleteDb({String dbName = 'titan_app.db'}) async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, dbName);
    return deleteDatabase(path);
  }

}
