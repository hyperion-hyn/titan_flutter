import 'package:titan/config.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/pages/wallet/model/erc20_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/eth_transfer_history.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

class EtherscanApi {
  String host = "";

  EtherscanApi() {
    if (WalletConfig.isMainNet) {
      host = Config.ETHERSCAN_API_URL;
    } else {
      host = "https://api-ropsten.etherscan.io";
    }
  }

  static String getTxDetailUrl(String txHash, bool isChinaMainland) {
    if (isChinaMainland && WalletConfig.isMainNet) {
      return "https://cn.etherscan.com/tx/$txHash";
    }

    if (WalletConfig.isMainNet) {
      return "https://cn.etherscan.io/tx/$txHash";
    } else {
      return "https://ropsten.etherscan.io/tx/$txHash";
    }
  }

  Future<List<EthTransferHistory>> queryEthHistory(String address, int page) async {
    Map result = await HttpCore.instance.get("$host/api", params: {
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
      return resultList.map((json) => EthTransferHistory.fromJson(json)).toList();
    } else {
      throw new Exception();
    }
  }

  Future<List<Erc20TransferHistory>> queryErc20History(String contractAddress, String address, int page) async {
    Map result = await HttpCore.instance.get("$host/api", params: {
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
      return resultList.map((json) => Erc20TransferHistory.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<BigInt> queryBalance(String address, [tag = 'latest']) async {
    Map result = await HttpCore.instance.get("$host/api", params: {
      "module": "account",
      "action": "balance",
      "apikey": Config.ETHERSCAN_APIKEY,
      "address": address,
      "tag": tag,
    });
    if (result['status'] == '1') {
      return BigInt.parse(result['result']);
    } else {
      return BigInt.from(0);
    }
  }

  Future<BigInt> queryErc20TokenBalance({String address, String contractAddress, tag = 'latest'}) async {
    Map result = await HttpCore.instance.get("$host/api", params: {
      "module": "account",
      "action": "tokenbalance",
      "apikey": Config.ETHERSCAN_APIKEY,
      "address": address,
      "contractaddress": contractAddress,
      "tag": tag,
    });
    if (result['status'] == '1') {
      return BigInt.parse(result['result']);
    } else {
      return BigInt.from(0);
    }
  }
}
