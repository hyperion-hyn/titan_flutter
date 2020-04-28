import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:titan/src/data/db/app_database.dart';

import 'search_history_dao.dart';

/// Create tables
void _createTablesV1(Batch batch) {
  batch.execute('DROP TABLE IF EXISTS ${SearchHistoryDao.kTable}');
  batch.execute('''
  create table ${SearchHistoryDao.kTable} (
  ${SearchHistoryDao.kColumnId} integer primary key autoincrement, 
  ${SearchHistoryDao.kColumnSearchText} text not null unique,
  ${SearchHistoryDao.kColumnType} text,
  ${SearchHistoryDao.kColumnTime} integer)
''');
}

class DBProvider {
  static Database _db;

  static Future<Database> open({String dbName = 'titan_app.db'}) async {
    if (_db != null && _db.isOpen) {
      return _db;
    }
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, dbName);
    //https://github.com/tekartik/sqflite/blob/93a20bee6eba0119cef5bada2700e67999ab20a9/sqflite/doc/migration_example.md
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        var batch = db.batch();
        _createTablesV1(batch);
        await batch.commit();
      },
    );
    return _db;
  }

  static Future<void> deleteDb({String dbName = 'titan_app.db'}) async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, dbName);
    return deleteDatabase(path);
  }
}
