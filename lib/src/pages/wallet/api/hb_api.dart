import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/vo/wallet_view_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/wallet/model/erc20_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/eth_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/hb_erc20_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/ht_transfer_history.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/config/ethereum.dart';
import 'package:titan/src/plugins/wallet/config/heco.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:web3dart/web3dart.dart' as web3;

class HbApi {
  static String getTxDetailUrl(String txHash) {
    return '${HecoExplore.hecoScanWeb}/tx/$txHash';
  }

  static String getAddressDetailUrl(String address) {
    return '${HecoExplore.hecoScanWeb}/address/$address';
  }

  Future<List<HtTransferHistory>> queryHtHistory(String address, int page) async {
    Map result =
        await HttpCore.instance.get("${HecoExplore.hecoScanApi}/v1/account/coin-tx-list", params: {
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

  Future<List<HbErc20TransferHistory>> queryHtErc20History(
      String contractAddress, String address, int page) async {
    Map result =
        await HttpCore.instance.get("${HecoExplore.hecoScanApi}/v1/account/token-tx-list", params: {
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
