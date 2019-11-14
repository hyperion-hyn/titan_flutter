import 'package:titan/config.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/business/wallet/model/erc20_transfer_history.dart';
import 'package:titan/src/business/wallet/model/eth_transfer_history.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

class EtherscanApi {
  String host = "";

  EtherscanApi() {
    if (WalletConfig.isMainNet) {
      host = "api.etherscan.io";
    } else {
      host = "api-ropsten.etherscan.io";
    }
  }

  Future<List<EthTransferHistory>> queryEthHistory(String address, int page) async {
    Map result = await HttpCore.instance.get("https://$host/api", params: {
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
    Map result = await HttpCore.instance.get("https://${host}/api", params: {
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
}
