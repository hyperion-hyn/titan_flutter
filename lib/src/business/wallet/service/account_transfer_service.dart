import 'package:titan/src/business/wallet/etherscan_api.dart';
import 'package:titan/src/business/wallet/model/erc20_transfer_history.dart';
import 'package:titan/src/business/wallet/model/eth_transfer_history.dart';
import 'package:titan/src/business/wallet/model/transtion_detail_vo.dart';
import 'package:titan/src/business/wallet/model/wallet_account_vo.dart';
import 'package:titan/src/plugins/wallet/convert.dart';

class AccountTransferService {
  EtherscanApi _etherscanApi = EtherscanApi();

  Future<List<TranstionDetailVo>> getTransferList(WalletAccountVo walletAccountVo, int page) async {
    if (walletAccountVo.symbol == "ETH") {
      return await _getEthTransferList(walletAccountVo, page);
    } else {
      return await _getErc20TransferList(walletAccountVo, page);
    }
  }

  Future<List<TranstionDetailVo>> _getErc20TransferList(WalletAccountVo walletAccountVo, int page) async {
    var contractAddress = walletAccountVo.assetToken.erc20ContractAddress;

    List<Erc20TransferHistory> erc20TransferHistoryList =
        await _etherscanApi.queryErc20History(contractAddress, walletAccountVo.account.address, page);

    List<TranstionDetailVo> detailList = erc20TransferHistoryList.map((erc20TransferHistory) {
      var type = 0;
      if (erc20TransferHistory.from == walletAccountVo.account.address.toLowerCase()) {
        type = TranstionType.TRANSFER_OUT;
      } else if (erc20TransferHistory.to == walletAccountVo.account.address.toLowerCase()) {
        type = TranstionType.TRANSFER_IN;
      }
      return TranstionDetailVo(
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

  Future<List<TranstionDetailVo>> _getEthTransferList(WalletAccountVo walletAccountVo, int page) async {
    List<EthTransferHistory> ethTransferHistoryList =
        await _etherscanApi.queryEthHistory(walletAccountVo.account.address, page);

    List<TranstionDetailVo> detailList = ethTransferHistoryList.map((ethTransferHistory) {
      var type = 0;
      if (ethTransferHistory.from == walletAccountVo.account.address.toLowerCase()) {
        type = TranstionType.TRANSFER_OUT;
      } else if (ethTransferHistory.to == walletAccountVo.account.address.toLowerCase()) {
        type = TranstionType.TRANSFER_IN;
      }
      return TranstionDetailVo(
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

class TranstionType {
  static const TRANSFER_OUT = 1;
  static const TRANSFER_IN = 2;
}
