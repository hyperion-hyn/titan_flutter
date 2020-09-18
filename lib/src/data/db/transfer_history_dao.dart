import 'package:sqflite/sqflite.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';
import '../entity/history_search.dart';

import 'db_provider.dart';

class TransferHistoryDao {
  static const String kTable = 'transfer_history';
  static const String kColumnId = 'id';
  static const String kColumnHash = 'hash';
  static const String kColumnNonce = 'nonce';
  static const String kColumnFromAddress = 'fromAddress';
  static const String kColumnToAddress = 'toAddress';
  static const String kColumnTime = 'time';
  static const String kColumnType = 'type';
  static const String kColumnSymbol = 'symbol';
  static const String kColumnAmount = 'amount';
  static const String kColumnGas = 'gas';
  static const String kColumnGasPrice = 'gasPrice';
  static const String kColumnContractAddress = 'contractAddress';
  static const String kColumnLocalTransferType = 'localTransferType';

  Future<TransactionDetailVo> insertOrUpdate(TransactionDetailVo entity) async {
    if (entity.id == null) {
      print("!!!!! insert");
      entity.id = await (await _db).rawInsert(
          'INSERT OR REPLACE INTO $kTable($kColumnHash, $kColumnNonce, $kColumnFromAddress, $kColumnToAddress'
          ', $kColumnTime, $kColumnType, $kColumnSymbol, $kColumnAmount, $kColumnGas, $kColumnGasPrice, $kColumnContractAddress, $kColumnLocalTransferType) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)',
          [
            entity.hash,
            entity.nonce,
            entity.fromAddress,
            entity.toAddress,
            entity.time,
            entity.type,
            entity.symbol,
            entity.amount,
            entity.gas,
            entity.gasPrice,
            entity.contractAddress,
            entity.localTransferType,
          ]);
    } else {
      print("!!!!! update ${entity.amount}");
      entity.id = await (await _db).rawInsert(
          'INSERT OR REPLACE INTO $kTable($kColumnId, $kColumnHash, $kColumnNonce, $kColumnFromAddress, $kColumnToAddress'
              ', $kColumnTime, $kColumnType, $kColumnSymbol, $kColumnAmount, $kColumnGas, $kColumnGasPrice, $kColumnContractAddress, $kColumnLocalTransferType) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)',
          [
            entity.id,
            entity.hash,
            entity.nonce,
            entity.fromAddress,
            entity.toAddress,
            entity.time,
            entity.type,
            entity.symbol,
            entity.amount,
            entity.gas,
            entity.gasPrice,
            entity.contractAddress,
            entity.localTransferType,
          ]);
    }
    return entity;
  }

  Future<List<TransactionDetailVo>> getList(int type, String fromAddress,{String contractAddress}) async {
    var result = [];
    if(type == LocalTransferType.LOCAL_TRANSFER_ETH) {
      result = await (await _db).query(kTable,
          where: '$kColumnLocalTransferType=? and $kColumnFromAddress=?',
          whereArgs: [type, fromAddress],
          orderBy: '$kColumnId DESC');
    }else if(type == LocalTransferType.LOCAL_TRANSFER_HYN_USDT){
      result = await (await _db).query(kTable,
          where: '$kColumnLocalTransferType=? and $kColumnFromAddress=? and $kColumnContractAddress=?',
          whereArgs: [type, fromAddress, contractAddress],
          orderBy: '$kColumnId DESC');
    }
    return result.map((item) => TransactionDetailVo.fromJson(item)).toList();
  }

  Future<String> getTransactionDBNonce(String fromAddress) async {
    var result = await (await _db).query(kTable,
        where: '$kColumnFromAddress=?',
        whereArgs: [fromAddress],
        offset:0,
        limit: 1,
        orderBy: '$kColumnId DESC');
    if(result.length > 0){
      List<TransactionDetailVo> transList = result.map((item) => TransactionDetailVo.fromJson(item)).toList();
      return transList[0].nonce;
    }
    return null;
  }

  Future<TransactionDetailVo> getTransactionWithTxHash(String txHash) async {
    var result = await (await _db).query(kTable,
        where: '$kColumnHash=?',
        whereArgs: [txHash],
        orderBy: '$kColumnId DESC');
    if(result.length > 0){
      List<TransactionDetailVo> transList = result.map((item) => TransactionDetailVo.fromJson(item)).toList();
      return transList[0];
    }
    return null;
  }

  Future<int> delete(int id) async {
    return await (await _db).delete(kTable, where: '$kColumnId=?', whereArgs: [id]);
  }

  Future<int> deleteSameNonce(String nonce) async {
    return await (await _db).delete(kTable, where: '$kColumnNonce=?', whereArgs: [nonce]);
  }

  Future<int> deleteAll() async {
    var result = await (await _db).delete(kTable);
    return result;
  }

  Future<Database> get _db async {
    return await DBProvider.open();
  }

}
