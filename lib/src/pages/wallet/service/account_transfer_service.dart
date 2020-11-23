import 'dart:collection';
import 'dart:convert';

import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/wallet/api/bitcoin_api.dart';
import 'package:titan/src/pages/wallet/api/etherscan_api.dart';
import 'package:titan/src/pages/wallet/model/bitcoin_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/erc20_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/eth_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/pages/wallet/model/hyn_transfer_history.dart';

class AccountTransferService {
  EtherscanApi _etherScanApi = EtherscanApi();
  AtlasApi _atlasApi = AtlasApi();

  Future<List<TransactionDetailVo>> getTransferList(
      CoinVo coinVo, int page) async {
    if (coinVo.symbol == "ETH") {
      return await _getEthTransferList(coinVo, page);
    } else if (coinVo.coinType == CoinType.HYN_ATLAS) {
      return await _getHYNAtlasTransferList(coinVo, page);
    } else if (coinVo.coinType == CoinType.BITCOIN) {
      return await _getBitcoinTransferList(coinVo, page);
    } else {
      return await _getErc20TransferList(coinVo, page);
    }
  }

  Future<List<TransactionDetailVo>> _getHYNAtlasTransferList(
      CoinVo coinVo, int page) async {
    List<HynTransferHistory> hynTransferHistoryList =
        await _atlasApi.queryHYNHistory(coinVo.address, page);

    List<TransactionDetailVo> detailList =
        hynTransferHistoryList.map((hynTransferHistory) {
      var type = 0;
      if (hynTransferHistory.from.toLowerCase() ==
          coinVo.address.toLowerCase()) {
        type = TransactionType.TRANSFER_OUT;
      } else if (hynTransferHistory.to.toLowerCase() ==
          coinVo.address.toLowerCase()) {
        type = TransactionType.TRANSFER_IN;
      }
      var transactionItem = TransactionDetailVo.fromHynTransferHistory(hynTransferHistory,type,coinVo.symbol);

      return transactionItem;
    }).toList();
    return detailList;
  }

  Future<List<TransactionDetailVo>> _getErc20TransferList(
      CoinVo coinVo, int page) async {
    List<Erc20TransferHistory> erc20TransferHistoryList = await _etherScanApi
        .queryErc20History(coinVo.contractAddress, coinVo.address, page);

    List<TransactionDetailVo> detailList =
        erc20TransferHistoryList.map((erc20TransferHistory) {
      var type = 0;
      if (erc20TransferHistory.from == coinVo.address.toLowerCase()) {
        type = TransactionType.TRANSFER_OUT;
      } else if (erc20TransferHistory.to == coinVo.address.toLowerCase()) {
        type = TransactionType.TRANSFER_IN;
      }
      return TransactionDetailVo(
        type: type,
        state: 1,
        amount: ConvertTokenUnit.weiToDecimal(
                BigInt.parse(erc20TransferHistory.value),
                int.parse(erc20TransferHistory.tokenDecimal))
            .toDouble(),
        symbol: erc20TransferHistory.tokenSymbol,
        fromAddress: erc20TransferHistory.from,
        toAddress: erc20TransferHistory.to,
        time: int.parse(erc20TransferHistory.timeStamp + "000"),
        hash: erc20TransferHistory.hash,
        gasPrice: erc20TransferHistory.gasPrice,
        gasUsed: erc20TransferHistory.gasUsed,
        gas: erc20TransferHistory.gas,
        nonce: erc20TransferHistory.nonce,
      );
    }).toList();
    return detailList;
  }

  Future<List<TransactionDetailVo>> _getEthTransferList(
      CoinVo coinVo, int page) async {
    List<EthTransferHistory> ethTransferHistoryList =
        await _etherScanApi.queryEthHistory(coinVo.address, page);

    List<TransactionDetailVo> detailList =
        ethTransferHistoryList.map((ethTransferHistory) {
      var type = 0;
      if (ethTransferHistory.from == coinVo.address.toLowerCase()) {
        type = TransactionType.TRANSFER_OUT;
      } else if (ethTransferHistory.to == coinVo.address.toLowerCase()) {
        type = TransactionType.TRANSFER_IN;
      }
      return TransactionDetailVo(
        type: type,
        state: int.parse(ethTransferHistory.txreceiptStatus),
        amount: ConvertTokenUnit.weiToEther(
                weiBigInt: BigInt.parse(ethTransferHistory.value))
            .toDouble(),
        symbol: "ETH",
        fromAddress: ethTransferHistory.from,
        toAddress: ethTransferHistory.to,
        time: int.parse(ethTransferHistory.timeStamp + "000"),
        hash: ethTransferHistory.hash,
        gasPrice: ethTransferHistory.gasPrice,
        gasUsed: ethTransferHistory.gasUsed,
        gas: ethTransferHistory.gas,
        nonce: ethTransferHistory.nonce,
      );
    }).toList();
    return detailList;
  }

  Future<List<TransactionDetailVo>> _getBitcoinTransferList(
      CoinVo coinVo, int page) async {
    List<BitcoinTransferHistory> bitcoinTransferList =
        await BitcoinApi.getBitcoinTransferList(
            coinVo.extendedPublicKey, page - 1, 10);

    List<TransactionDetailVo> detailList =
        bitcoinTransferList.map((bitcoinTransferHistory) {
      var type = 0;
      if (bitcoinTransferHistory.amount < 0) {
        type = TransactionType.TRANSFER_OUT;
      } else if (bitcoinTransferHistory.amount >= 0) {
        type = TransactionType.TRANSFER_IN;
      }
      return TransactionDetailVo(
        type: type,
        state: bitcoinTransferHistory.nConfirmed,
        amount: ConvertTokenUnit.weiToDecimal(
                BigInt.parse(bitcoinTransferHistory.amount.toString()), 8)
            .toDouble(),
        symbol: coinVo.symbol,
        fromAddress: bitcoinTransferHistory.fromAddr,
        toAddress: bitcoinTransferHistory.toAddr,
        time: bitcoinTransferHistory.confirmAt * 1000,
        hash: bitcoinTransferHistory.txHash,
        gasUsed: bitcoinTransferHistory.fee.toString(),
      );
    }).toList();
    return detailList;
  }
}

class TransactionType {
  static const TRANSFER_OUT = 1;
  static const TRANSFER_IN = 2;
}

class TransactionStatus {
  static const PENDING = 0;
  static const FAILED = -1;
  static const CONFIRMED = 1;
}
