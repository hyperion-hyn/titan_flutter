import 'package:sqflite/sqflite.dart';
import 'package:titan/env.dart';
import 'package:titan/src/pages/wallet/model/transaction_info_vo.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';
import '../entity/history_search.dart';

import 'db_provider.dart';

class TxnInfoDao {
  static const String kTable = 'txn_info';
  static const String kColumnId = 'id';
  static const String kColumnChain = 'chain';
  static const String kColumnNetwork = 'network';
  static const String kColumnAddress = 'address';
  static const String kColumnHash = 'hash';
  static const String kColumnTime = 'time';
  static const String kColumnFromAddress = 'fromAddress';
  static const String kColumnToAddress = 'toAddress';
  static const String kColumnSymbol = 'symbol';
  static const String kColumnAmount = 'amount';
  static const String kColumnStatus = 'status';

  Future<TransactionInfoVo> insertOrUpdate(TransactionInfoVo entity) async {
    entity.id = await (await _db).rawInsert(
        'INSERT OR REPLACE INTO $kTable($kColumnChain,$kColumnNetwork,$kColumnAddress, $kColumnHash, $kColumnTime, $kColumnFromAddress, $kColumnToAddress, $kColumnSymbol, $kColumnAmount,$kColumnStatus) VALUES(?,?,?,?,?,?,?,?,?,?)',
        [
          entity.chain,
          env.buildType == BuildType.DEV ? 'test-net' : 'main-net',
          entity.address,
          entity.hash,
          entity.time,
          entity.fromAddress,
          entity.toAddress,
          entity.symbol,
          entity.amount,
          entity.status,
        ]);
    return entity;
  }

  Future<List<TransactionInfoVo>> getListByChainAndSymbol(
    String chain,
    String network,
    String symbol,
    String address, {
    int offset: 0,
    int limit: 20,
  }) async {
    var result = await (await _db).query(kTable,
        where: '$kColumnAddress=? and $kColumnChain=? and $kColumnNetwork=? and $kColumnSymbol=? ',
        whereArgs: [address, chain, network, symbol],
        offset: offset,
        limit: limit,
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
