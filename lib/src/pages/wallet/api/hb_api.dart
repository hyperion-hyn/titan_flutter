

import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/pages/wallet/model/erc20_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/eth_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/hb_erc20_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/ht_transfer_history.dart';
import 'package:titan/src/plugins/wallet/config/heco.dart';

class HbApi{
  static String getTxDetailUrl(String txHash) {
    return '${HecoExplore.hecoScanWeb}/tx/$txHash';
  }

  Future<List<HtTransferHistory>> queryHtHistory(String address, int page) async {
    address = "0xFC20F6a8A1A65a91F838247b4F460437a5a68bCA";
    Map result = await HttpCore.instance.get("${HecoExplore.hecoScanApi}/v1/account/coin-tx-list", params: {
      "address": address,
      "startBlock": "0",
      "endBlock": "99999999",
      "page": page,
      "offset": "10",
      "sort": "desc",
    });

    if (result["code"] == 0) {
      List resultList = result["data"] as List;
      return resultList.map((json) => HtTransferHistory.fromJson(json)).toList();
    } else {
      throw new Exception();
    }
  }

  Future<List<HbErc20TransferHistory>> queryHtErc20History(String contractAddress, String address, int page) async {
    contractAddress = "0xeF3CEBD77E0C52cb6f60875d9306397B5Caca375";
    address = "0xF5b1C2613211171eC6dD9d5B8F2F13a9AC287A98";
    Map result = await HttpCore.instance.get("${HecoExplore.hecoScanApi}/v1/account/token-tx-list", params: {
      "contractAddress": contractAddress,
      "address": address,
      "startBlock": "0",
      "endBlock": "99999999",
      "page": page,
      "offset": "10",
      "sort": "desc",
    });
    if (result["code"] == 0) {
      List resultList = result["data"] as List;
      return resultList.map((json) => HbErc20TransferHistory.fromJson(json)).toList();
    } else {
      throw new Exception();
    }
  }
}