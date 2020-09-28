import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/wallet/model/bitcoin_transfer_history.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/plugins/wallet/bitcoin_trans_entity.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'dart:math';

import 'package:titan/src/utils/log_util.dart';

class BitcoinApi {
  static Future<dynamic> requestBitcoinBalance(String pubString) async {
    var response;
    try {
      print("balance request $pubString");
      response = await HttpCore.instance.post(WalletConfig.getBitcoinApi() + "balance",
          data: {"pub": pubString}, options: RequestOptions(contentType: Headers.jsonContentType));
    } catch (exception) {
      LogUtil.uploadException(exception, 'bitcoin balance upload');
    }
    return response;
  }

  static Future syncBitcoinPubToServer(String btcAddress, String pubString) async {
    var createValue = await AppCache.getValue(btcAddress);
    if (createValue != "create") {
      var response = await HttpCore.instance.post(WalletConfig.getBitcoinApi() + "create",
          data: {"pub": pubString, "version": "P2WPKH"}, options: RequestOptions(contentType: Headers.jsonContentType));
      if (response != null && response["code"] == 0) {
        AppCache.saveValue(btcAddress, "create");
      }
    }
  }

  static Future<dynamic> sendBitcoinTransaction(
      String fileName, String password, String pubString, String toAddr, int fee, int amount) async {
    BitcoinTransEntity bitcoinTransEntity = await HttpCore.instance.postEntity(
        WalletConfig.getBitcoinApi() + "utxo",
        EntityFactory<BitcoinTransEntity>(
          (json) => BitcoinTransEntity.fromJson(json),
        ),
        data: {"pub": pubString, "to_addr": toAddr, "fee": fee, "amount": amount}, //
        options: RequestOptions(contentType: Headers.jsonContentType));
    bitcoinTransEntity.fileName = fileName;
    bitcoinTransEntity.password = password;
    bitcoinTransEntity.toAddress = toAddr;
    bitcoinTransEntity.fee = fee;
    bitcoinTransEntity.amount = amount;
    String rawTx = await TitanPlugin.signBitcoinRawTx(json.encode(bitcoinTransEntity.toJson()));

    var randomNum = Random().nextInt(bitcoinTransEntity.utxo.length);
    var response = await HttpCore.instance.post(WalletConfig.getBitcoinApi() + "txRaw",
        data: {"address": bitcoinTransEntity.utxo[randomNum].address, "raw": rawTx},
        options: RequestOptions(contentType: Headers.jsonContentType));
    return response;
  }

  static Future<List<BitcoinTransferHistory>> getBitcoinTransferList(String pubString, int page, int pageSize) async {
    print("pubString");
    return await HttpCore.instance.postEntity(WalletConfig.getBitcoinApi() + "txs",
        EntityFactory<List<BitcoinTransferHistory>>((json) {
      return (json as List).map((entity) => BitcoinTransferHistory.fromJson(entity)).toList();
    }),
        data: {"pub": pubString, "page": page, "pageSize": pageSize},
        options: RequestOptions(contentType: Headers.jsonContentType));
  }

  static Future<dynamic> requestBtcFeeRecommend() async {
    return await HttpCore.instance
        .get(WalletConfig.getBitcoinApi() + "fee", options: RequestOptions(contentType: Headers.jsonContentType));
  }

  //{ address:string, appType:int, email:string, hynBalance:string, map3Staking:string}

  static Future postWalletBalance(String address, int appType, String email, String hynBalance,
      {String map3Staking = "0"}) async {
    try {

      Map<String, dynamic> params = {
        "address": address,
        "appType": appType,
        "email": email,
        "hynBalance": hynBalance.isEmpty?"0":hynBalance,
        "map3Staking": map3Staking,
      };

      await HttpCore.instance.post(WalletConfig.WALLET_ADDRESS_API,
          params: params,
          options: RequestOptions(contentType: Headers.jsonContentType));
    } catch (exception) {
      LogUtil.uploadException(exception, '[postWalletBalance]');
    }
  }
}
