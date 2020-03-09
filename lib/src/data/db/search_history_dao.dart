import 'package:sqflite/sqflite.dart';
import '../entity/history_search.dart';

import 'db_provider.dart';

class SearchHistoryDao {
  static const String kTable = 'search_history';
  static const String kColumnId = 'id';
  static const String kColumnTime = 'time';
  static const String kColumnSearchText = 'search_text';
  static const String kColumnType = 'type';

  Future<HistorySearchEntity> insertOrUpdate(HistorySearchEntity entity) async {
    entity.id = await (await _db).rawInsert(
        'INSERT OR REPLACE INTO $kTable($kColumnTime, $kColumnSearchText, $kColumnType) VALUES(?,?,?)',
        [entity.time, entity.searchText, entity.type]);
//    entity.id = await (await _db).insert(kTable, entity.toJson());
    return entity;
  }

  Future<List<HistorySearchEntity>> getList({int offset: 0, int limit: 20}) async {
    var result = await (await _db).query(kTable, offset: offset, limit: limit, orderBy: '$kColumnId DESC');
    return result.map((item) => HistorySearchEntity.fromJson(item)).toList();
  }

  Future<int> delete(int id) async {
    return await (await _db).delete(kTable, where: '$kColumnId=?', whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    var result = await (await _db).delete(kTable);
    return result;
  }

  Future<Database> get _db async {
    return await DBProvider.open();
  }
}
