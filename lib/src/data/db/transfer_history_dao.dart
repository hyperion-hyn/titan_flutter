import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';

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

  Future<bool> insertTransaction(TransactionDetailVo vo, int localTransferType, String erc20Address) async {
    List<TransactionDetailVo> txsByAddress = await getTransactions(vo.fromAddress, localTransferType, erc20Address);
    bool isReplaced = false;
    for (var i = 0; i < txsByAddress.length; i++) {
      if (txsByAddress[i].nonce == vo.nonce) {
        var tx = txsByAddress[i];
        vo.speedUpTimes = tx.speedUpTimes;
        vo.cancelTimes = tx.cancelTimes;
        txsByAddress[i] = vo;
        isReplaced = true;
        break;
      }
    }
    if (!isReplaced) {
      vo.speedUpTimes = 0;
      vo.cancelTimes = 0;
      txsByAddress.add(vo);
    }

    if (vo.lastOptType == OptType.SPEED_UP) {
      vo.speedUpTimes++;
    } else if (vo.lastOptType == OptType.CANCEL) {
      vo.cancelTimes++;
    }

    List jsonList = List();
    txsByAddress.map((item) => jsonList.add(item.toJson())).toList();
    var encoded = json.encode(jsonList);
    return AppCache.saveValue(_getStoreKey(vo.fromAddress, localTransferType, erc20Address), encoded);
  }

  Future<bool> deleteTransactionSmallOrEqualThanNonce(
      String fromAddress, int localTransferType, String erc20Address, int nonce) async {
    List<TransactionDetailVo> txsByAddress = await getTransactions(fromAddress, localTransferType, erc20Address);

    var txs = txsByAddress.where((element) {
      print('element.nonce ${element.nonce} $nonce');
      return int.parse(element.nonce) > nonce;
    }).toList();

    if (txs.length < txsByAddress.length) {
      List jsonList = List();
      txs.map((item) => jsonList.add(item.toJson())).toList();
      var encoded = json.encode(jsonList);
      return AppCache.saveValue(_getStoreKey(fromAddress, localTransferType, erc20Address), encoded);
    }
    return true;
  }

  Future<List<TransactionDetailVo>> getTransactions(
      String fromAddress, int localTransferType, String erc20Address) async {
    var encoded = await AppCache.getValue(_getStoreKey(fromAddress, localTransferType, erc20Address));
    if (encoded != null && encoded != '') {
      List decoded = json.decode(encoded);
      var deList = decoded.map((item) => TransactionDetailVo.fromJson(item)).toList();
      if(deList.length > 1) {
        deList.sort(([a, b]) => int.parse(b.nonce) - int.parse(a.nonce));
      }
      return deList;
    }
    /*else {
      //兼容旧的pending
      var vo = await getShareTransaction(localTransferType, fromAddress, contractAddress: erc20Address);
      if (vo != null) {
        await AppCache.remove(PrefsKey.PENDING_TRANSFER_KEY_PREFIX + fromAddress);
        await insertTransaction(vo, localTransferType, erc20Address);
        return [vo];
      }
    }*/

    return [];
  }

  String _getStoreKey(String fromAddress, int localTransferType, String erc20Address) {
    return PrefsKey.PENDING_TRANSACTIONS_KEY_PREFIX +
        fromAddress +
        '_${localTransferType ?? 0}_' +
        (erc20Address ?? '0');
  }

  Future<TransactionDetailVo> getTransactionByNonce(
      String fromAddress, int localTransferType, String erc20Address, nonce) async {
    var encoded = await AppCache.getValue(_getStoreKey(fromAddress, localTransferType, erc20Address));
    if (encoded != null && encoded != '') {
      List decoded = json.decode(encoded);
      for (var item in decoded) {
        if (item['nonce'] == nonce) {
          return TransactionDetailVo.fromJson(item);
        }
      }
    }

    return null;
  }

  // Future<TransactionDetailVo> insertOrUpdate(TransactionDetailVo entity) async {
  //   String fromAddress =
  //       WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet?.wallet?.getEthAccount()?.address ?? "";
  //   if (fromAddress.isEmpty) {
  //     return null;
  //   }
  //   await AppCache.saveValue(PrefsKey.PENDING_TRANSFER_KEY_PREFIX + fromAddress, json.encode(entity.toJson()));
  //
  //   return entity;
  // }

  // Future<TransactionDetailVo> getShareTransaction(int type, String fromAddress,
  //     {String contractAddress, bool isAll}) async {
  //   String entityStr = await AppCache.getValue(PrefsKey.PENDING_TRANSFER_KEY_PREFIX + fromAddress);
  //   if (entityStr == null) {
  //     return null;
  //   }
  //   var transcactionEntity = TransactionDetailVo.fromJson(json.decode(entityStr));
  //   if (isAll == true) {
  //     return transcactionEntity;
  //   }
  //   if (type == LocalTransferType.LOCAL_TRANSFER_ETH) {
  //     if (transcactionEntity.localTransferType == LocalTransferType.LOCAL_TRANSFER_ETH &&
  //         transcactionEntity.fromAddress == fromAddress) {
  //       return transcactionEntity;
  //     }
  //   } else if (type == LocalTransferType.LOCAL_TRANSFER_ERC20) {
  //     if (transcactionEntity.localTransferType == LocalTransferType.LOCAL_TRANSFER_ERC20 &&
  //         transcactionEntity.fromAddress == fromAddress &&
  //         transcactionEntity.contractAddress == contractAddress) {
  //       return transcactionEntity;
  //     }
  //   }
  //   return null;
  // }

  Future<List<TransactionDetailVo>> getList(int type, String fromAddress, {String contractAddress}) async {
    var result = [];
    if (type == LocalTransferType.LOCAL_TRANSFER_ETH) {
      result = await (await _db).query(kTable,
          where: '$kColumnLocalTransferType=? and $kColumnFromAddress=?',
          whereArgs: [type, fromAddress],
          orderBy: '$kColumnId DESC');
    } else if (type == LocalTransferType.LOCAL_TRANSFER_ERC20) {
      result = await (await _db).query(kTable,
          where: '$kColumnLocalTransferType=? and $kColumnFromAddress=? and $kColumnContractAddress=?',
          whereArgs: [type, fromAddress, contractAddress],
          orderBy: '$kColumnId DESC');
    }
    return result.map((item) => TransactionDetailVo.fromJson(item)).toList();
  }

  Future<String> getTransactionDBNonce(String fromAddress) async {
    var result = await (await _db).query(kTable,
        where: '$kColumnFromAddress=?', whereArgs: [fromAddress], offset: 0, limit: 1, orderBy: '$kColumnId DESC');
    if (result.length > 0) {
      List<TransactionDetailVo> transList = result.map((item) => TransactionDetailVo.fromJson(item)).toList();
      return transList[0].nonce;
    }
    return null;
  }

  Future<TransactionDetailVo> getTransactionWithTxHash(String txHash) async {
    var result =
        await (await _db).query(kTable, where: '$kColumnHash=?', whereArgs: [txHash], orderBy: '$kColumnId DESC');
    if (result.length > 0) {
      List<TransactionDetailVo> transList = result.map((item) => TransactionDetailVo.fromJson(item)).toList();
      return transList[0];
    }
    return null;
  }

  Future<int> delete(int id) async {
    return await (await _db).delete(kTable, where: '$kColumnId=?', whereArgs: [id]);
  }

  // Future deleteSameNonce() async {
  //   String fromAddress =
  //       WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet?.wallet?.getEthAccount()?.address ?? "";
  //   if (fromAddress.isEmpty) {
  //     return;
  //   }
  //   await AppCache.remove(PrefsKey.PENDING_TRANSFER_KEY_PREFIX + fromAddress);
  // }

  Future<int> deleteAll() async {
    var result = await (await _db).delete(kTable);
    return result;
  }

  Future<Database> get _db async {
    return await DBProvider.open();
  }
}
