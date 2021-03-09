import 'package:sqflite/sqflite.dart';
import 'package:titan/src/pages/wallet/model/transaction_info_vo.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';
import '../entity/history_search.dart';

import 'db_provider.dart';

class TxnInfoDao {
  static const String kTable = 'txn_info';
  static const String kColumnId = 'id';
  static const String kColumnChain = 'chain';
  static const String kColumnAddress = 'address';
  static const String kColumnHash = 'hash';
  static const String kColumnTime = 'time';
  static const String kColumnFromAddress = 'fromAddress';
  static const String kColumnToAddress = 'toAddress';
  static const String kColumnSymbol = 'symbol';
  static const String kColumnAmount = 'amount';
  static const String kColumnStatus = 'status';

  Future<TransactionInfoVo> insertOrUpdate(TransactionInfoVo entity, String address) async {
    entity.id = await (await _db).rawInsert(
        'INSERT OR REPLACE INTO $kTable($kColumnChain,$kColumnAddress, $kColumnHash, $kColumnTime, $kColumnFromAddress, $kColumnToAddress, $kColumnSymbol, $kColumnAmount,$kColumnStatus) VALUES(?,?,?,?,?,?,?,?,?)',
        [
          entity.chain,
          address,
          entity.hash,
          entity.time,
          entity.from,
          entity.to,
          entity.symbol,
          entity.amount,
          entity.status,
        ]);
    return entity;
  }

  Future<List<TransactionInfoVo>> getListByChain(
    String chain,
    String address, {
    int offset: 0,
  }) async {
    var result = await (await _db).query(kTable,
        where: '$kColumnAddress=? and $kColumnChain=?',
        whereArgs: [address, chain],
        orderBy: '$kColumnId DESC');
    return result.map((item) => TransactionInfoVo.fromJson(item)).toList();
  }

  Future<int> delete(int id) async {
    return await (await _db).delete(kTable, where: '$kColumnAddress=?', whereArgs: [id]);
  }

  Future<int> deleteByChainAndHash(String address, String chain, String hash) async {
    return await (await _db).delete(
      kTable,
      where: '$kColumnChain=? and $kColumnAddress=? and $kColumnHash=?',
      whereArgs: [chain, address, hash],
    );
  }

  Future<int> deleteAll() async {
    var result = await (await _db).delete(kTable);
    return result;
  }

  Future<Database> get _db async {
    return await DBProvider.open();
  }
}
