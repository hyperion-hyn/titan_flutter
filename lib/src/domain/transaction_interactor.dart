import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/repository/repository.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';
import 'package:titan/src/pages/wallet/service/account_transfer_service.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:web3dart/credentials.dart';

class TransactionInteractor {
  Repository repository;

  TransactionInteractor(this.repository);

  Future insertTransactionDB(String hash, String toAddress, BigInt value, BigInt gasPrice,
      int gasLimit, int transType, int nonce,
      {int id, contractAddress}) async {
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
    } else if (transType == LocalTransferType.LOCAL_TRANSFER_HYN_USDT) {
      walletVo.coins.forEach((element) {
        if (element.contractAddress == contractAddress) {
          symbol = element.symbol;
          decimal = element.decimals;
        }
      });
      if (symbol == "USDT") {
        symbol = "Tether USD";
      }
      amount = ConvertTokenUnit.weiToDecimal(BigInt.parse(value.toString()), decimal).toDouble();
    }
    TransactionDetailVo transactionDetailVo = TransactionDetailVo(
        id: id,
        hash: hash,
        localTransferType: transType,
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
    await repository.transferHistoryDao.insertOrUpdate(transactionDetailVo);
  }

  Future<TransactionDetailVo> getShareTransaction(int type, bool isAll, {String contractAddress}) async {
    String fromAddress =
        WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet?.wallet?.getEthAccount()?.address ?? "";
    var entity = await repository.transferHistoryDao.getShareTransaction(type, fromAddress, contractAddress: contractAddress,isAll: isAll);
    return entity;
  }

  Future<List<TransactionDetailVo>> getTransactionList(int type, {String contractAddress}) {
    String fromAddress =
        WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet?.wallet?.getEthAccount()?.address ?? "";
    return repository.transferHistoryDao.getList(type, fromAddress, contractAddress: contractAddress);
  }

  Future deleteSameNonce(String nonce) async {
    var tranEntity = await getShareTransaction(LocalTransferType.LOCAL_TRANSFER_ETH,true);
    if(tranEntity == null){
      return ;
    }
    if(int.parse(nonce) >= int.parse(tranEntity.nonce)){
      repository.transferHistoryDao.deleteSameNonce();
    }
  }

  Future<String> showPasswordDialog(BuildContext context) async {
    var activeWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    var password = await UiUtil.showWalletPasswordDialogV2(context, activeWallet);
    if(password == null){
      return null;
    }
    return password;
  }

  Future cancelTransaction(BuildContext context, TransactionDetailVo transactionDetailVo,String password) async {
    var gasPriceRecommend = WalletInheritedModel.of(context, aspect: WalletAspect.gasPrice).gasPriceRecommend;
    var walletVo = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;

    var amount = ConvertTokenUnit.etherToWei(etherDouble: 0);
    Decimal maxGasPrice = gasPriceRecommend.fast;
    Decimal speedGasPrice = Decimal.parse(transactionDetailVo.gasPrice) * Decimal.parse("1.1");
    Decimal resultGasPrice;
    if(speedGasPrice < maxGasPrice){
      resultGasPrice = speedGasPrice;
    }else{
      resultGasPrice = maxGasPrice;
    }

    if (transactionDetailVo.localTransferType == LocalTransferType.LOCAL_TRANSFER_ETH) {
      var txHash = await walletVo.wallet.sendEthTransaction(
          id: transactionDetailVo.id,
          password: password,
          value: amount,
          toAddress: transactionDetailVo.toAddress,
          gasPrice: BigInt.from(resultGasPrice.toInt()),
          nonce: int.parse(transactionDetailVo.nonce));
      logger.i('ETH交易已提交，交易hash $txHash');
    } else if (transactionDetailVo.localTransferType == LocalTransferType.LOCAL_TRANSFER_HYN_USDT) {
      var txHash = await walletVo.wallet.sendErc20Transaction(
          id: transactionDetailVo.id,
          contractAddress: transactionDetailVo.contractAddress,
          password: password,
          gasPrice: BigInt.from(resultGasPrice.toInt()),
          value: amount,
          toAddress: transactionDetailVo.toAddress,
          nonce: int.parse(transactionDetailVo.nonce));
      logger.i('HYN USDT transaction committed，txhash $txHash ');
    }
  }

  Future speedTransaction(BuildContext context, TransactionDetailVo transactionDetailVo,String password) async {
    var gasPriceRecommend = WalletInheritedModel.of(context, aspect: WalletAspect.gasPrice).gasPriceRecommend;
    var walletVo = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;

    Decimal maxGasPrice = gasPriceRecommend.fast;
    Decimal speedGasPrice = Decimal.parse(transactionDetailVo.gasPrice) * Decimal.parse("1.1");
    Decimal resultGasPrice;
    if(speedGasPrice < maxGasPrice){
      resultGasPrice = speedGasPrice;
    }else{
      resultGasPrice = maxGasPrice;
    }

    if (transactionDetailVo.localTransferType == LocalTransferType.LOCAL_TRANSFER_ETH) {
      var amount = ConvertTokenUnit.etherToWei(etherDouble: transactionDetailVo.amount);
      var txHash = await walletVo.wallet.sendEthTransaction(
          id: transactionDetailVo.id,
          password: password,
          value: amount,
          toAddress: transactionDetailVo.toAddress,
          gasPrice: BigInt.from(resultGasPrice.toInt()),
          nonce: int.parse(transactionDetailVo.nonce));
      logger.i('ETH交易已提交，交易hash $txHash');
    } else if (transactionDetailVo.localTransferType == LocalTransferType.LOCAL_TRANSFER_HYN_USDT) {
      int decimal;
      walletVo.coins.forEach((element) {
        if (element.contractAddress == transactionDetailVo.contractAddress) {
          decimal = element.decimals;
        }
      });
      var amount = ConvertTokenUnit.numToWei(transactionDetailVo.amount, decimal);
      var txHash = await walletVo.wallet.sendErc20Transaction(
          id: transactionDetailVo.id,
          contractAddress: transactionDetailVo.contractAddress,
          password: password,
          gasPrice: BigInt.from(resultGasPrice.toInt()),
          value: amount,
          toAddress: transactionDetailVo.toAddress,
          nonce: int.parse(transactionDetailVo.nonce));
      logger.i('ETH交易已提交，交易hash $txHash');
    }
  }

  Future<String> getTransactionDBNonce(String fromAddress) {
    return repository.transferHistoryDao.getTransactionDBNonce(fromAddress);
  }

}
