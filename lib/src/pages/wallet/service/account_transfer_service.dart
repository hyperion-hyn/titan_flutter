import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/pages/wallet/api/etherscan_api.dart';
import 'package:titan/src/pages/wallet/model/erc20_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/eth_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';
import 'package:titan/src/plugins/wallet/convert.dart';

class AccountTransferService {
  EtherscanApi _etherScanApi = EtherscanApi();

  Future<List<TransactionDetailVo>> getTransferList(CoinVo coinVo, int page) async {
    if (coinVo.symbol == "ETH") {
      return await _getEthTransferList(coinVo, page);
    } else {
      return await _getErc20TransferList(coinVo, page);
    }
  }

  Future<List<TransactionDetailVo>> _getErc20TransferList(CoinVo coinVo, int page) async {
    List<Erc20TransferHistory> erc20TransferHistoryList =
        await _etherScanApi.queryErc20History(coinVo.contractAddress, coinVo.address, page);

    List<TransactionDetailVo> detailList = erc20TransferHistoryList.map((erc20TransferHistory) {
      var type = 0;
      if (erc20TransferHistory.from == coinVo.address.toLowerCase()) {
        type = TransactionType.TRANSFER_OUT;
      } else if (erc20TransferHistory.to == coinVo.address.toLowerCase()) {
        type = TransactionType.TRANSFER_IN;
      }
      return TransactionDetailVo(
          type: type,
          state: 0,
          amount: ConvertTokenUnit.weiToDecimal(BigInt.parse(erc20TransferHistory.value)).toDouble(),
          unit: erc20TransferHistory.tokenSymbol,
          fromAddress: erc20TransferHistory.from,
          toAddress: erc20TransferHistory.to,
          time: int.parse(erc20TransferHistory.timeStamp + "000"),
          hash: erc20TransferHistory.hash);
    }).toList();
    return detailList;
  }

  Future<List<TransactionDetailVo>> _getEthTransferList(CoinVo coinVo, int page) async {
    List<EthTransferHistory> ethTransferHistoryList = await _etherScanApi.queryEthHistory(coinVo.address, page);

    List<TransactionDetailVo> detailList = ethTransferHistoryList.map((ethTransferHistory) {
      var type = 0;
      if (ethTransferHistory.from == coinVo.address.toLowerCase()) {
        type = TransactionType.TRANSFER_OUT;
      } else if (ethTransferHistory.to == coinVo.address.toLowerCase()) {
        type = TransactionType.TRANSFER_IN;
      }
      return TransactionDetailVo(
          type: type,
          state: 0,
          amount: ConvertTokenUnit.weiToDecimal(BigInt.parse(ethTransferHistory.value)).toDouble(),
          unit: "ETH",
          fromAddress: ethTransferHistory.from,
          toAddress: ethTransferHistory.to,
          time: int.parse(ethTransferHistory.timeStamp + "000"),
          hash: ethTransferHistory.hash);
    }).toList();
    return detailList;
  }
}

class TransactionType {
  static const TRANSFER_OUT = 1;
  static const TRANSFER_IN = 2;
}
