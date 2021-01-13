import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/repository/repository.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';
import 'package:titan/src/pages/wallet/service/account_transfer_service.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:web3dart/credentials.dart';

class TransactionInteractor {
  Repository repository;

  TransactionInteractor(this.repository);

  Future<bool> insertTransactionDB(
      String hash, String toAddress, BigInt value, BigInt gasPrice, int gasLimit, int transType, int nonce,
      {int optType, contractAddress}) async {
    WalletVo walletVo = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    String fromAddress = walletVo.wallet.getEthAccount().address;
    int time = DateTime.now().millisecondsSinceEpoch;
//    if(nonce == null){
//      nonce = await WalletUtil.getWeb3Client()
//          .getTransactionCount(EthereumAddress.fromHex(fromAddress));
//    }
    var symbol;
    double amount;
    int decimal;
    if (transType == LocalTransferType.LOCAL_TRANSFER_ETH || transType == LocalTransferType.LOCAL_TRANSFER_MAP3) {
      symbol = "ETH";
      amount = ConvertTokenUnit.weiToDecimal(BigInt.parse(value.toString())).toDouble();
    } else if (transType == LocalTransferType.LOCAL_TRANSFER_ERC20) {
      walletVo.coins.forEach((element) {
        if (element.contractAddress == contractAddress) {
          symbol = element.symbol;
          decimal = element.decimals;
        }
      });
      // if (symbol == "USDT") {
      //   symbol = "Tether USD";
      // }
      amount = ConvertTokenUnit.weiToDecimal(BigInt.parse(value.toString()), decimal).toDouble();
    }
    TransactionDetailVo transactionDetailVo = TransactionDetailVo(
        lastOptType: optType,
        localTransferType: transType,
        hash: hash,
        time: time,
        type: TransactionType.TRANSFER_OUT,
        symbol: symbol,
        toAddress: toAddress,
        amount: amount,
        gasPrice: gasPrice.toString(),
        nonce: nonce.toString(),
        gas: gasLimit.toString(),
        fromAddress: fromAddress,
        contractAddress: contractAddress);
    // await repository.transferHistoryDao.insertOrUpdate(transactionDetailVo);
    return repository.transferHistoryDao.insertTransaction(transactionDetailVo, transType, contractAddress);
  }

  Future<List<TransactionDetailVo>> getLocalPendingTransactions(
      String fromAddress, int localTransferType, String erc20Address) {
    return repository.transferHistoryDao.getTransactions(fromAddress, localTransferType, erc20Address);
  }

  // Future<TransactionDetailVo> getShareTransaction(int type, bool isAll, {String contractAddress}) async {
  //   String fromAddress =
  //       WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet?.wallet?.getEthAccount()?.address ?? "";
  //   var entity = await repository.transferHistoryDao
  //       .getShareTransaction(type, fromAddress, contractAddress: contractAddress, isAll: isAll);
  //   return entity;
  // }

  // Future<List<TransactionDetailVo>> getTransactionList(int type, {String contractAddress}) {
  //   String fromAddress =
  //       WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet?.wallet?.getEthAccount()?.address ?? "";
  //   return repository.transferHistoryDao.getList(type, fromAddress, contractAddress: contractAddress);
  // }

  Future<bool> removeLocalPendingConfirmedTxsByNonce(
      String fromAddress, int localTransferType, String erc20Address, int nextNonce) async {
    var _ethAddress = fromAddress;
    if (_ethAddress != null) {
      if (nextNonce > 0) {
        return _confirmTransactionOfNonce(_ethAddress, localTransferType, erc20Address, nextNonce - 1);
      }
    }
    return false;
  }

  Future<bool> removeLocalPendingConfirmedTxsOfAddress(
      String fromAddress, int localTransferType, String erc20Address) async {
    var _ethAddress = fromAddress;
    if (_ethAddress != null) {
      final client = WalletUtil.getWeb3Client(false);
      var nextNonce = await client.getTransactionCount(EthereumAddress.fromHex(_ethAddress));
      if (nextNonce > 0) {
        return _confirmTransactionOfNonce(_ethAddress, localTransferType, erc20Address, nextNonce - 1);
      }
    }
    return false;
  }

  Future<bool> _confirmTransactionOfNonce(
      String fromAddress, int localTransferType, String erc20Address, int nonce) async {
    // var tranEntity = await getShareTransaction(LocalTransferType.LOCAL_TRANSFER_ETH, true);
    // if (tranEntity == null) {
    //   return;
    // }
    // if (int.parse(nonce) >= int.parse(tranEntity.nonce)) {
    //   repository.transferHistoryDao.deleteSameNonce();
    // }
    return repository.transferHistoryDao
        .deleteTransactionSmallOrEqualThanNonce(fromAddress, localTransferType, erc20Address, nonce);
  }

  Future<String> showPasswordDialog(BuildContext context) async {
    var activeWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    var password = await UiUtil.showWalletPasswordDialogV2(context, activeWallet);
    if (password == null) {
      return null;
    }
    return password;
  }

  Future<String> cancelTransaction(BuildContext context, TransactionDetailVo vo, String password) async {
    // var amount = ConvertTokenUnit.etherToWei(etherDouble: 0);
    return _replaceTransaction(context, vo, password, OptType.CANCEL);
  }

  Future<String> speedUpTransaction(BuildContext context, TransactionDetailVo vo, String password) async {
    // var amount = ConvertTokenUnit.etherToWei(etherDouble: vo.amount);
    return _replaceTransaction(context, vo, password, OptType.SPEED_UP);
  }

  Future<String> _replaceTransaction(BuildContext context, TransactionDetailVo transactionDetailVo, String password, int optType) async {
    var gasPriceRecommend = WalletInheritedModel.of(context, aspect: WalletAspect.gasPrice).gasPriceRecommend;
    var walletVo = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;

    Decimal maxGasPrice = gasPriceRecommend.fast;
    Decimal speedGasPrice = Decimal.parse(transactionDetailVo.gasPrice) * Decimal.parse("1.1");
    Decimal resultGasPrice;
    if (speedGasPrice < maxGasPrice) {
      resultGasPrice = maxGasPrice;
    } else {
      resultGasPrice = speedGasPrice;
    }

    double amount = optType == OptType.SPEED_UP ? transactionDetailVo.amount : 0;
    if (transactionDetailVo.localTransferType == LocalTransferType.LOCAL_TRANSFER_ETH) {
      var txHash = await walletVo.wallet.sendEthTransaction(
          optType: optType,
          password: password,
          value: ConvertTokenUnit.etherToWei(etherDouble: amount),
          toAddress: transactionDetailVo.toAddress,
          gasPrice: BigInt.parse(resultGasPrice.toString()),
          nonce: int.parse(transactionDetailVo.nonce));
      logger.i('ETH交易已提交，交易nonce ${transactionDetailVo.nonce}, hash $txHash');
      return txHash;
    } else if (transactionDetailVo.localTransferType == LocalTransferType.LOCAL_TRANSFER_ERC20) {
      int decimal;
      walletVo.coins.forEach((element) {
        if (element.contractAddress == transactionDetailVo.contractAddress) {
          decimal = element.decimals;
        }
      });
      var txHash = await walletVo.wallet.sendErc20Transaction(
          optType: optType,
          contractAddress: transactionDetailVo.contractAddress,
          password: password,
          gasPrice: BigInt.parse(resultGasPrice.toString()),
          value: ConvertTokenUnit.numToWei(amount, decimal),
          toAddress: transactionDetailVo.toAddress,
          nonce: int.parse(transactionDetailVo.nonce));
      logger.i('ETH交易已提交，交易hash $txHash');
      return txHash;
    }
    return null;
  }

// Future<String> getTransactionDBNonce(String fromAddress) {
//   return repository.transferHistoryDao.getTransactionDBNonce(fromAddress);
// }
}
