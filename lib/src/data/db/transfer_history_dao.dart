import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
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
    String fromAddress =
        WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet?.wallet?.getEthAccount()?.address ?? "";
    if(fromAddress.isEmpty){
      return null;
    }
    await AppCache.saveValue(PrefsKey.PENDING_TRANSFER_KEY_PREFIX + fromAddress, json.encode(entity.toJson()));

    return entity;
  }

  Future<TransactionDetailVo> getShareTransaction(int type, String fromAddress,{String contractAddress,bool isAll}) async {
    String entityStr = await AppCache.getValue(PrefsKey.PENDING_TRANSFER_KEY_PREFIX + fromAddress);
    if(entityStr == null){
      return null;
    }
    var transcactionEntity = TransactionDetailVo.fromJson(json.decode(entityStr));
    if(isAll){
      return transcactionEntity;
    }
    if(type == LocalTransferType.LOCAL_TRANSFER_ETH){
      if(transcactionEntity.localTransferType == LocalTransferType.LOCAL_TRANSFER_ETH
          && transcactionEntity.fromAddress == fromAddress){
        return transcactionEntity;
      }
    }else if (type == LocalTransferType.LOCAL_TRANSFER_HYN_USDT){
      if(transcactionEntity.localTransferType == LocalTransferType.LOCAL_TRANSFER_HYN_USDT
          && transcactionEntity.fromAddress == fromAddress
          && transcactionEntity.contractAddress == contractAddress){
        return transcactionEntity;
      }
    }
    return null;
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

  Future deleteSameNonce() async {
    String fromAddress =
        WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet?.wallet?.getEthAccount()?.address ?? "";
    if(fromAddress.isEmpty){
      return;
    }
    await AppCache.remove(PrefsKey.PENDING_TRANSFER_KEY_PREFIX + fromAddress);
  }

  Future<int> deleteAll() async {
    var result = await (await _db).delete(kTable);
    return result;
  }

  Future<Database> get _db async {
    return await DBProvider.open();
  }

}
