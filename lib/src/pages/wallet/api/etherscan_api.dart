import 'package:flutter/widgets.dart';
import 'package:titan/config.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/pages/wallet/model/erc20_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/eth_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/hyn_transfer_history.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';

class EtherscanApi {
  String get apiHost {
    switch (WalletConfig.netType) {
      case EthereumNetType.main:
        return Config.ETHERSCAN_API_URL;
      case EthereumNetType.ropsten:
        return Config.ETHERSCAN_API_URL_ROPSTEN;
      case EthereumNetType.rinkeby:
        return Config.ETHERSCAN_API_URL_RINKEBY;

//      case EthereumNetType.local:
//        return Config.ETHERSCAN_API_URL;
      default:
        return Config.ETHERSCAN_API_URL;
    }
  }

  static String getWebHost(bool isChinaMainland) {
    if (WalletConfig.netType == EthereumNetType.main) {
      if (isChinaMainland) {
        return 'https://cn.etherscan.com';
      } else {
        return "https://etherscan.io";
      }
    } else if (WalletConfig.netType == EthereumNetType.ropsten) {
      return "https://ropsten.etherscan.io";
    } else if (WalletConfig.netType == EthereumNetType.rinkeby) {
      return "https://rinkeby.etherscan.io";
    }
    return '';
  }

  static String getTxDetailUrl(String txHash, bool isChinaMainland) {
    return '${getWebHost(isChinaMainland)}/tx/$txHash';
  }

  static String getAddressDetailUrl(String address, bool isChinaMainland) {
    return '${getWebHost(isChinaMainland)}/address/$address';
  }

  Future<List<EthTransferHistory>> queryEthHistory(
      String address, int page) async {
    Map result = await HttpCore.instance.get("$apiHost/api", params: {
      "module": "account",
      "action": "txlist",
      "address": address,
      "startblock": "0",
      "endblock": "99999999",
      "page": page,
      "offset": "10",
      "sort": "desc",
      "apikey": Config.ETHERSCAN_APIKEY,
    });

    if (result["status"] == "1") {
      List resultList = result["result"] as List;
      return resultList
          .map((json) => EthTransferHistory.fromJson(json))
          .toList();
    } else {
      throw new Exception();
    }
  }

  Future<List<Erc20TransferHistory>> queryErc20History(
      String contractAddress, String address, int page) async {
    Map result = await HttpCore.instance.get("$apiHost/api", params: {
      "module": "account",
      "action": "tokentx",
      "contractaddress": contractAddress,
      "page": page,
      "offset": "10",
      "sort": "desc",
      "apikey": Config.ETHERSCAN_APIKEY,
      "address": address
    });
    if (result["status"] == "1") {
      List resultList = result["result"] as List;
      return resultList
          .map((json) => Erc20TransferHistory.fromJson(json))
          .toList();
    } else {
      return [];
    }
  }

  Future<ResponseEntity> getGasFromEtherScan() async {
    Map json = await HttpCore.instance.get("$apiHost/api", params: {
      "module": "gastracker",
      "action": "gasoracle",
      "apikey": Config.ETHERSCAN_APIKEY,
    });

    if (json["status"] == "1") {
      return ResponseEntity.fromJson(json);
    } else {
      throw new Exception();
    }
  }

//  Future<BigInt> queryBalance(String address, [tag = 'latest']) async {
//    Map result = await HttpCore.instance.get("$host/api", params: {
//      "module": "account",
//      "action": "balance",
//      "apikey": Config.ETHERSCAN_APIKEY,
//      "address": address,
//      "tag": tag,
//    });
//    if (result['status'] == '1') {
//      return BigInt.parse(result['result']);
//    } else {
//      return BigInt.from(0);
//    }
//  }

//  Future<BigInt> queryErc20TokenBalance({String address, String contractAddress, tag = 'latest'}) async {
//    Map result = await HttpCore.instance.get("$host/api", params: {
//      "module": "account",
//      "action": "tokenbalance",
//      "apikey": Config.ETHERSCAN_APIKEY,
//      "address": address,
//      "contractaddress": contractAddress,
//      "tag": tag,
//    });
//    if (result['status'] == '1') {
//      return BigInt.parse(result['result']);
//    } else {
//      return BigInt.from(0);
//    }
//  }
}
