
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/pages/wallet/model/bitcoin_transfer_history.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/plugins/wallet/bitcoin_trans_entity.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';

class BitcoinApi{

  static Future<dynamic> requestBitcoinBalance(String pubString) async {
    var response;
    try {
      print("balance request $pubString");
      response = await HttpCore.instance.post(WalletConfig.getBitcoinApi() + "balance",
          data: {"pub": pubString},
          options: RequestOptions(contentType: Headers.jsonContentType));
    }catch(exception){
      print("!!!!!!!!!$exception");
    }
    return response;
  }

  static Future<dynamic> syncBitcoinPubToServer(String pubString, String version) async {
    return await HttpCore.instance.post(WalletConfig.getBitcoinApi() + "create",
        data: {"pub": pubString, "version": version},
        options: RequestOptions(contentType: Headers.jsonContentType));
  }

  static Future<dynamic> sendBitcoinTransaction(String fileName, String password, String pubString, String toAddr, int fee, int amount) async {
    BitcoinTransEntity bitcoinTransEntity = await HttpCore.instance.postEntity(
        WalletConfig.getBitcoinApi() + "utxo",
        EntityFactory<BitcoinTransEntity>(
              (json) => BitcoinTransEntity.fromJson(json),
        ),
        data: {"pub": pubString, "to_addr": toAddr, "fee": fee, "amount": amount},
        options: RequestOptions(contentType: Headers.jsonContentType));
    bitcoinTransEntity.fileName = fileName;
    bitcoinTransEntity.password = password;
    bitcoinTransEntity.toAddress = toAddr;
    bitcoinTransEntity.fee = fee;
    bitcoinTransEntity.amount = amount;
    String rawTx = await TitanPlugin.signBitcoinRawTx(json.encode(bitcoinTransEntity.toJson()));

    print("!!!!!!!!$rawTx");
    var response = await HttpCore.instance.post(
        WalletConfig.getBitcoinApi() + "txRaw",
        data: {"pub": pubString, "raw": rawTx},
        options: RequestOptions(contentType: Headers.jsonContentType));
    print("!!!!!!!result = $response");
    return response;
  }

  static Future<List<BitcoinTransferHistory>> getBitcoinTransferList(String pubString, int page,int pageSize) async {
    return await HttpCore.instance.postEntity(WalletConfig.getBitcoinApi() + "txs",
        EntityFactory<List<BitcoinTransferHistory>>((json){
          return (json as List).map((entity)=>BitcoinTransferHistory.fromJson(entity)).toList();
        }
        ),
        data: {"pub": pubString, "page": page, "pageSize": pageSize},
        options: RequestOptions(contentType: Headers.jsonContentType));
  }

  static Future<dynamic> requestBtcFeeRecommend() async {
    return await HttpCore.instance.get(WalletConfig.getBitcoinApi() + "fee",
        options: RequestOptions(contentType: Headers.jsonContentType));
  }

}