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
import 'package:web3dart/credentials.dart';

class TransactionInteractor {
  Repository repository;

  TransactionInteractor(this.repository);

  Future insertTransactionDB(String hash, String password, String toAddress, BigInt value, BigInt gasPrice,
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
      print("!!!!! symbol $symbol $amount $decimal");
    }
    TransactionDetailVo transactionDetailVo = TransactionDetailVo(
        id: id,
        hash: hash,
        localTransferType: transType,
        time: time,
        type: TransactionType.TRANSFER_OUT,
        symbol: symbol,
        password: password,
        toAddress: toAddress,
        amount: amount,
        gasPrice: gasPrice.toString(),
        nonce: nonce.toString(),
        gas: gasLimit.toString(),
        fromAddress: fromAddress,
        contractAddress: contractAddress);
    await repository.transferHistoryDao.insertOrUpdate(transactionDetailVo);
  }

  Future<List<TransactionDetailVo>> getTransactionList(int type, {String contractAddress}) {
    String fromAddress =
        WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet.getEthAccount().address;
    return repository.transferHistoryDao.getList(type, fromAddress, contractAddress: contractAddress);
  }

  Future<int> deleteSameNonce(String nonce) {
    return repository.transferHistoryDao.deleteSameNonce(nonce);
  }

  Future cancelTransaction(TransactionDetailVo transactionDetailVo) async {
    var activeWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    var amount = ConvertTokenUnit.etherToWei(etherDouble: 0);
    var gasPrice = int.parse(transactionDetailVo.gasPrice) + (10 * TokenUnit.G_WEI);
    print(
        "!!!!!$gasPrice ${int.parse(transactionDetailVo.gasPrice)} ${transactionDetailVo.gasPrice} ${10 * TokenUnit.G_WEI}");
    print("!!!!!amount $amount ${transactionDetailVo.id} ${transactionDetailVo.nonce}");

    if (transactionDetailVo.localTransferType == LocalTransferType.LOCAL_TRANSFER_ETH) {
      var txHash = await activeWallet.sendEthTransaction(
          id: transactionDetailVo.id,
          password: transactionDetailVo.password,
          value: amount,
          toAddress: transactionDetailVo.toAddress,
          gasPrice: BigInt.from(gasPrice),
          nonce: int.parse(transactionDetailVo.nonce));
      logger.i('ETH交易已提交，交易hash $txHash');
    } else if (transactionDetailVo.localTransferType == LocalTransferType.LOCAL_TRANSFER_HYN_USDT) {
      var txHash = await activeWallet.sendErc20Transaction(
          id: transactionDetailVo.id,
          contractAddress: transactionDetailVo.contractAddress,
          password: transactionDetailVo.password,
          gasPrice: BigInt.parse(gasPrice.toStringAsFixed(0)),
          value: amount,
          toAddress: transactionDetailVo.toAddress,
          nonce: int.parse(transactionDetailVo.nonce));
      logger.i('HYN USDT transaction committed，txhash $txHash ');
    }
  }

  Future speedTransaction(TransactionDetailVo transactionDetailVo) async {
    WalletVo walletVo = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    var gasPrice = int.parse(transactionDetailVo.gasPrice) + (10 * TokenUnit.G_WEI);
    print(
        "!!!!!$gasPrice ${int.parse(transactionDetailVo.gasPrice)} ${transactionDetailVo.gasPrice} ${10 * TokenUnit.G_WEI}");
//    print("!!!!!amount $amount ${transactionDetailVo.id} ${transactionDetailVo.nonce}");

    if (transactionDetailVo.localTransferType == LocalTransferType.LOCAL_TRANSFER_ETH) {
      var amount = ConvertTokenUnit.etherToWei(etherDouble: transactionDetailVo.amount);
      var txHash = await walletVo.wallet.sendEthTransaction(
          id: transactionDetailVo.id,
          password: transactionDetailVo.password,
          value: amount,
          toAddress: transactionDetailVo.toAddress,
          gasPrice: BigInt.from(gasPrice),
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
          password: transactionDetailVo.password,
          gasPrice: BigInt.from(gasPrice),
          value: amount,
          toAddress: transactionDetailVo.toAddress,
          nonce: int.parse(transactionDetailVo.nonce));
      logger.i('ETH交易已提交，交易hash $txHash');
    }
  }

  Future<String> getTransactionDBNonce(String fromAddress) {
    return repository.transferHistoryDao.getTransactionDBNonce(fromAddress);
  }

  Future cancelMap3Delegate(String approveTxHash, String delegateTxHash) async {
    var transferHistoryDao = repository.transferHistoryDao;
    var approveTransactionDetail = await transferHistoryDao.getTransactionWithTxHash(approveTxHash);
    var delegateTransactionDetail = await transferHistoryDao.getTransactionWithTxHash(delegateTxHash);
    var activeWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    var amount = ConvertTokenUnit.etherToWei(etherDouble: 0);
    var approveGasPrice = int.parse(approveTransactionDetail.gasPrice) + (10 * TokenUnit.G_WEI);
    var delegateGasPrice = int.parse(delegateTransactionDetail.gasPrice) + (10 * TokenUnit.G_WEI);

    //approve
    var approveHex = await activeWallet.sendApproveErc20Token(
        contractAddress: approveTransactionDetail.contractAddress,
        approveToAddress: approveTransactionDetail.toAddress,
        amount: amount,
        password: approveTransactionDetail.password,
        gasPrice: BigInt.from(approveGasPrice),
        gasLimit: int.parse(approveTransactionDetail.gas),
        nonce: int.parse(approveTransactionDetail.nonce),
        isStore: true);
    print('approveHex is: $approveHex');

    var joinHex = await activeWallet.sendDelegateMap3Node(
      createNodeWalletAddress: delegateTransactionDetail.toAddress,
      stakingAmount: amount,
      gasPrice: BigInt.from(delegateGasPrice),
      gasLimit: int.parse(delegateTransactionDetail.gas),
      password: delegateTransactionDetail.password,
      nonce: int.parse(delegateTransactionDetail.nonce),
    );
    print('joinHex is: $joinHex');
  }

  Future speedMap3Delegate(
      String approveTxHash, String delegateTxHash, void speedSuccees(), void speedError(String exception)) async {
    var transferHistoryDao = repository.transferHistoryDao;
    var activeWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;

    var approveTransactionDetail = await transferHistoryDao.getTransactionWithTxHash(approveTxHash);
    if (approveTransactionDetail != null) {
      try {
        var approveAmount = ConvertTokenUnit.etherToWei(etherDouble: approveTransactionDetail.amount);
        var approveGasPrice = int.parse(approveTransactionDetail.gasPrice) + (10 * TokenUnit.G_WEI);

        //approve
        var approveHex = await activeWallet.sendApproveErc20Token(
            contractAddress: approveTransactionDetail.contractAddress,
            approveToAddress: approveTransactionDetail.toAddress,
            amount: approveAmount,
            password: approveTransactionDetail.password,
            gasPrice: BigInt.from(approveGasPrice),
            gasLimit: int.parse(approveTransactionDetail.gas),
            nonce: int.parse(approveTransactionDetail.nonce),
            isStore: true,
            id: approveTransactionDetail.id);
        print('approveHex is: $approveHex');
      } catch (exception) {
        if (exception.toString().contains("nonce too low") || exception.toString().contains("known transaction")) {
          print('approveHex is: complete');
        }
        print('approveHex is: error ${exception.toString()}');
      }
    }

    var delegateTransactionDetail = await transferHistoryDao.getTransactionWithTxHash(delegateTxHash);
    if (delegateTransactionDetail != null) {
      try {
        var delegateAmount = ConvertTokenUnit.etherToWei(etherDouble: delegateTransactionDetail.amount);
        var delegateGasPrice = int.parse(delegateTransactionDetail.gasPrice) + (10 * TokenUnit.G_WEI);

        var joinHex = await activeWallet.sendDelegateMap3Node(
            createNodeWalletAddress: delegateTransactionDetail.toAddress,
            stakingAmount: delegateAmount,
            gasPrice: BigInt.from(delegateGasPrice),
            gasLimit: int.parse(delegateTransactionDetail.gas),
            password: delegateTransactionDetail.password,
            nonce: int.parse(delegateTransactionDetail.nonce),
            id: delegateTransactionDetail.id);
        print('joinHex is: $joinHex');
        speedSuccees();
      } catch (exception) {
        if (exception.toString().contains("nonce too low") || exception.toString().contains("known transaction")) {
          speedError(exception.toString());
        }
        print('joinHex is: error ${exception.toString()}');
      }
    }
  }

  Future speedMap3Withdraw(String withdrawTxHash, void speedSuccees(), void speedError(String exception)) async {
    var activeWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    var transferHistoryDao = repository.transferHistoryDao;
    var withdrawTransactionDetail = await transferHistoryDao.getTransactionWithTxHash(withdrawTxHash);
    if (withdrawTransactionDetail != null) {
      try {
        var withdrawGasPrice = int.parse(withdrawTransactionDetail.gasPrice) + (10 * TokenUnit.G_WEI);

        var collectHex = await activeWallet.sendCollectMap3Node(
            createNodeWalletAddress: withdrawTransactionDetail.toAddress,
            gasPrice: BigInt.from(withdrawGasPrice),
            gasLimit: int.parse(withdrawTransactionDetail.gas),
            password: withdrawTransactionDetail.password,
            nonce: int.parse(withdrawTransactionDetail.nonce),
            id: withdrawTransactionDetail.id);
        print('collectHex is: $collectHex');
        speedSuccees();
      } catch (exception) {
        if (exception.toString().contains("nonce too low") || exception.toString().contains("known transaction")) {
          print('approveHex is: complete');
          speedError(exception.toString());
        }
        print('approveHex is: error ${exception.toString()}');
      }
    }
  }
}
