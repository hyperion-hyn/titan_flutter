import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/setting/system_config_entity.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/domain/transaction_interactor.dart';
import 'package:titan/src/pages/wallet/api/bitcoin_api.dart';
import 'package:titan/src/pages/wallet/api/hyn_api.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet_channel.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:web3dart/web3dart.dart';

import 'wallet_util.dart';

part 'wallet.g.dart';

@JsonSerializable()
class Wallet {
  ///activated account of this wallet,  btc, eth etc.
  List<Account> accounts;
  KeyStore keystore;
  TransactionInteractor transactionInteractor = Injector.of(Keys.rootKey.currentContext).transactionInteractor;

  Wallet({this.keystore, this.accounts});

  Future<BigInt> getErc20Balance(String contractAddress) async {
    var account = getEthAccount();
    if (account != null) {
      return getBalanceByCoinTypeAndAddress(account.coinType, account.address, contractAddress);
    }

    return BigInt.from(0);
  }

  Account getEthAccount() {
    for (var account in accounts) {
      if (account.coinType == CoinType.ETHEREUM) {
        return account;
      }
    }
    return null;
  }

  Account getAtlasAccount() {
    for (var account in accounts) {
      if (account.coinType == CoinType.HYN_ATLAS) {
        return account;
      }
    }
    return null;
  }

  Account getBitcoinAccount() {
    for (var account in accounts) {
      if (account.coinType == CoinType.BITCOIN) {
        return account;
      }
    }
    return null;
  }

  String getBitcoinZPub() {
    for (var account in accounts) {
      if (account.coinType == CoinType.BITCOIN) {
        return account.extendedPublicKey;
      }
    }
    return "";
  }

  AssetToken getHynToken() {
    var tokens = getEthAccount()?.contractAssetTokens;
    if (tokens != null) {
      for (var token in tokens) {
        if (token.symbol == 'HYN') {
          return token;
        }
      }
    }
    return null;
  }

  ///get balance of account
  ///@param block: an integer block number, or the string "latest", "earliest" or "pending"
  Future<BigInt> getBalance(Account account, [dynamic block = 'latest']) async {
    if (account != null) {
      return getBalanceByCoinTypeAndAddress(account.coinType, account.address);
    }
    return BigInt.from(0);
  }

  Future<BigInt> getBalanceByCoinTypeAndAddress(int coinType, String address,
      [String contractAddress, String block = 'latest']) async {
    return WalletUtil.getBalanceByCoinTypeAndAddress(coinType, address, contractAddress, block);
  }

  Future<BigInt> getAllowance(
    String contractAddress,
    String ownAddress,
    String approveToAddress,
      bool isAtlas,
  ) async {
    final contract = WalletUtil.getHynErc20Contract(contractAddress);
    final balanceFun = contract.function('allowance');
    final allowance = await WalletUtil.getWeb3Client(isAtlas).call(
        contract: contract,
        function: balanceFun,
        params: [web3.EthereumAddress.fromHex(ownAddress), web3.EthereumAddress.fromHex(approveToAddress)]);
    return allowance.first;
  }

  Future<BigInt> getBitcoinBalance(String pubString) async {
    var response = await BitcoinApi.requestBitcoinBalance(pubString);
    if (response != null && response['code'] == 0) {
      return BigInt.from(response['data']);
    }
    return BigInt.from(0);
  }

  Future<BigInt> estimateGasPrice({
    @required String toAddress,
    // Integer of the gas provided for the transaction execution.
    BigInt gasLimit,
    //Integer of the gasPrice used for each paid gas
    BigInt gasPrice,
    //Integer of the value sent with this transaction
    BigInt value,
    //Hash of the method signature and encoded parameters. For details see Ethereum Contract ABI
    String data,
  }) async {
    var account = getEthAccount();
    SystemConfigEntity systemConfigEntity =
        SettingInheritedModel.ofConfig(Keys.rootKey.currentContext).systemConfigEntity;
    if (account != null) {
      if (gasLimit == null) {
        if (data == null) {
          gasLimit = BigInt.from(systemConfigEntity.ethTransferGasLimit);
        } else {
          gasLimit = BigInt.from(systemConfigEntity.erc20TransferGasLimit);
        }
      }
      if (gasPrice == null) {
        gasPrice = BigInt.from(EthereumConst.FAST_SPEED);
      }
      var params = {};
      params['from'] = account.address;
      params['to'] = toAddress;
      params['gas'] = '0x${gasLimit.toRadixString(16)}';
      params['gasPrice'] = '0x${gasPrice.toRadixString(16)}';
      if (value != null) {
        params['value'] = '0x${value.toRadixString(16)}';
      }
      if (data != null) {
        params['data'] = data;
      }
      var response = await WalletUtil.postToEthereumNetwork(method: 'eth_estimateGas', params: [params]);
      if (response['result'] != null) {
        BigInt amountUsed = hexToInt(response['result']);
//        return amountUsed * gasPrice;
        return amountUsed;
      }
    }

    return BigInt.from(0);
  }

  Future<int> getCurrentWalletNonce({int nonce}) async {
    if (nonce == null) {
      WalletVo walletVo = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
      String fromAddress = walletVo.wallet.getEthAccount().address;
      nonce = await WalletUtil.getWeb3Client().getTransactionCount(EthereumAddress.fromHex(fromAddress));
//      String localNonce = await transactionInteractor.getTransactionDBNonce(fromAddress);
//      if (localNonce != null && int.parse(localNonce) >= nonce) {
//        nonce = int.parse(localNonce) + 1;
//      }
    }
    return nonce;
  }

  /// 发送转账
  /// 如果[type]设置为 web3.MessageType.typeNormal 则是 Atlas转账
  /// 如果[message]设置了，则为抵押相关的操作
  /// 如果[type]和[message]都是null，则为ethereum转账
  Future<String> sendEthTransaction(
      {int id,
      String password,
      String toAddress,
      BigInt value,
      BigInt gasPrice,
      int nonce,
      int gasLimit = 0,
      int type,
      web3.IMessage message,
      bool isAtlasTrans = false}) async {
    /*if (gasLimit == 0) {
      gasLimit = SettingInheritedModel.ofConfig(Keys.rootKey.currentContext).systemConfigEntity.ethTransferGasLimit;
    }

    var privateKey = await WalletUtil.exportPrivateKey(fileName: keystore.fileName, password: password);
    final client = WalletUtil.getWeb3Client(isAtlasTrans);
    final credentials = await client.credentialsFromPrivateKey(privateKey);
    final txHash = await client.sendTransaction(
      credentials,
      web3.Transaction(
        to: toAddress == null ? null :web3.EthereumAddress.fromHex(toAddress),
        gasPrice: web3.EtherAmount.inWei(gasPrice),
        maxGas: gasLimit,
        value: value == null ? null : web3.EtherAmount.inWei(value),
        nonce: nonce,
        type: type,
        message: message,
      ),
      fetchChainIdFromNetworkId: type == null ? true : false,
    );*/

    final signedRawHex = await signEthTransaction(
      password: password,
      toAddress: toAddress,
      gasPrice: gasPrice,
      value: value,
      type: type,
      message: message,
      isAtlasTrans: isAtlasTrans,
      gasLimit: gasLimit,
      nonce: nonce,
    );

    var responseMap = await WalletUtil.postToEthereumNetwork(
        method: 'eth_sendRawTransaction', params: [signedRawHex], isAtlasTrans: isAtlasTrans);
    if (type == null && responseMap['result'] != null) {
      nonce = await getCurrentWalletNonce();
      await transactionInteractor.insertTransactionDB(
          responseMap['result'], toAddress, value, gasPrice, gasLimit, LocalTransferType.LOCAL_TRANSFER_ETH, nonce,
          id: id);
    } else if (responseMap['error'] != null) {
      var errorEntity = responseMap['error'];
      throw RPCError(errorEntity['code'], errorEntity['message'], "");
    }

    return responseMap['result'];
  }

  /// 签名转账
  /// 如果[type]设置为 web3.MessageType.typeNormal 则是 Atlas转账
  /// 如果[message]设置了，则为抵押相关的操作
  /// 如果[type]和[message]都是null，则为ethereum转账
  Future<String> signEthTransaction(
      {int id,
      String password,
      String toAddress,
      BigInt value,
      BigInt gasPrice,
      int nonce,
      int gasLimit = 0,
      int type,
      web3.IMessage message,
      bool isAtlasTrans = false}) async {
    if (gasLimit == 0) {
      gasLimit = SettingInheritedModel.ofConfig(Keys.rootKey.currentContext).systemConfigEntity.ethTransferGasLimit;
    }

    var privateKey = await WalletUtil.exportPrivateKey(fileName: keystore.fileName, password: password);
    final client = WalletUtil.getWeb3Client(isAtlasTrans);
    final credentials = await client.credentialsFromPrivateKey(privateKey);
    final rawTx = await client.signTransaction(
      credentials,
      web3.Transaction(
        to: toAddress == null ? null : web3.EthereumAddress.fromHex(toAddress),
        gasPrice: web3.EtherAmount.inWei(gasPrice),
        maxGas: gasLimit,
        value: value == null ? null : web3.EtherAmount.inWei(value),
        nonce: nonce,
        type: type,
        message: message,
      ),
      fetchChainIdFromNetworkId: type == null ? true : false,
    );

    return bytesToHex(rawTx, include0x: true, padToEvenLength: true);
  }

  Future<String> sendErc20Transaction({
    int id,
    String contractAddress,
    String password,
    String toAddress,
    BigInt value,
    BigInt gasPrice,
    int nonce,
    int gasLimit = 0,
  }) async {
    if (gasLimit == 0) {
      gasLimit = SettingInheritedModel.ofConfig(Keys.rootKey.currentContext).systemConfigEntity.erc20TransferGasLimit;
    }
//    nonce = await getCurrentWalletNonce(nonce: nonce);

    var ethBalance = WalletInheritedModel.of(Keys.rootKey.currentContext).getCoinVoBySymbol('ETH').balance;

    var gasFees = BigInt.from(gasLimit) * gasPrice;
    if (gasFees > ethBalance) {
      Fluttertoast.showToast(msg: "ETH余额不足以支付gas费");
      return null;
    }

    var privateKey = await WalletUtil.exportPrivateKey(fileName: keystore.fileName, password: password);
    final client = WalletUtil.getWeb3Client();
    final credentials = await client.credentialsFromPrivateKey(privateKey);
    final contract = WalletUtil.getHynErc20Contract(contractAddress);
    final txHash = await client.sendTransaction(
      credentials,
      web3.Transaction.callContract(
        contract: contract,
        function: contract.function('transfer'),
        parameters: [web3.EthereumAddress.fromHex(toAddress), value],
        gasPrice: web3.EtherAmount.inWei(gasPrice),
        maxGas: gasLimit,
        nonce: nonce,
      ),
      fetchChainIdFromNetworkId: true,
    );

    if (txHash != null) {
      nonce = await getCurrentWalletNonce();
      await transactionInteractor.insertTransactionDB(
          txHash, toAddress, value, gasPrice, gasLimit, LocalTransferType.LOCAL_TRANSFER_HYN_USDT, nonce,
          id: id, contractAddress: contractAddress);
    } else {
      Fluttertoast.showToast(msg: "广播异常");
    }
    return txHash;
  }

  Future<String> sendHYNHrc30Transaction({
    int id,
    String contractAddress,
    String password,
    String toAddress,
    BigInt value,
    BigInt gasPrice,
    int nonce,
    int gasLimit = 0,
  }) async {

    var hynBalance = WalletInheritedModel.of(Keys.rootKey.currentContext).getCoinVoBySymbol('HYN').balance;

    var gasFees = BigInt.from(gasLimit) * gasPrice;
    if (gasFees > hynBalance) {
      Fluttertoast.showToast(msg: "HYN余额不足以支付gas费");
      return null;
    }

    var privateKey = await WalletUtil.exportPrivateKey(fileName: keystore.fileName, password: password);
    final client = WalletUtil.getWeb3Client(true);
    final credentials = await client.credentialsFromPrivateKey(privateKey);
    final contract = WalletUtil.getHynErc20Contract(contractAddress);
    final txHash = await client.sendTransaction(
      credentials,
      web3.Transaction.callContract(
          contract: contract,
          function: contract.function('transfer'),
          parameters: [web3.EthereumAddress.fromHex(toAddress), value],
          gasPrice: web3.EtherAmount.inWei(gasPrice),
          maxGas: gasLimit,
          nonce: nonce,
          type: MessageType.typeNormal),
      fetchChainIdFromNetworkId: false,
    );

    if (txHash == null) {
      Fluttertoast.showToast(msg: "广播异常");
    }
    return txHash;
  }

  Future<dynamic> sendBitcoinTransaction(String password, String pubString, String toAddr, int fee, int amount) async {
    var transResult =
        await BitcoinApi.sendBitcoinTransaction(keystore.fileName, password, pubString, toAddr, fee, amount);
    return transResult;
  }

  Future<String> bitcoinActive(String password) async {
    var result = await TitanPlugin.bitcoinActive(keystore.fileName, password);
    return result;
  }

  Future<web3.Credentials> getCredentials(String password) async {
    var privateKey = await WalletUtil.exportPrivateKey(fileName: keystore.fileName, password: password);
    final client = WalletUtil.getWeb3Client();
    final credentials = await client.credentialsFromPrivateKey(privateKey);
    return credentials;
  }


  Future<String> sendApproveErc20Token({
    String contractAddress,
    String approveToAddress,
    String password,
    BigInt amount,
    BigInt gasPrice,
    int gasLimit,
    int nonce,
    bool isAtlas = false,
  }) async {
    final client = WalletUtil.getWeb3Client(isAtlas);
    var credentials = await getCredentials(password);
    var erc20Contract = WalletUtil.getHynErc20Contract(contractAddress);
    final txHash = await client.sendTransaction(
      credentials,
      web3.Transaction.callContract(
        contract: erc20Contract,
        function: erc20Contract.function('approve'),
        parameters: [web3.EthereumAddress.fromHex(approveToAddress), amount],
        gasPrice: web3.EtherAmount.inWei(gasPrice),
        maxGas: gasLimit,
        nonce: nonce,
        type: isAtlas ? MessageType.typeNormal : null,
      ),
      fetchChainIdFromNetworkId: !isAtlas,
    );

//    await transactionInteractor.insertTransactionDB(
//        txHash, approveToAddress, amount, gasPrice, gasLimit, LocalTransferType.LOCAL_TRANSFER_MAP3, nonce,
//        contractAddress: contractAddress);
    return txHash;
  }

  Future<String> signApproveErc20Token({
    String contractAddress,
    String approveToAddress,
    String password,
    BigInt amount,
    BigInt gasPrice,
    int gasLimit,
    int nonce,
    bool isAtlas = false,
  }) async {
    final client = WalletUtil.getWeb3Client(isAtlas);
    var credentials = await getCredentials(password);
    var erc20Contract = WalletUtil.getHynErc20Contract(contractAddress);
    var signed = await client.signTransaction(
      credentials,
      web3.Transaction.callContract(
        contract: erc20Contract,
        function: erc20Contract.function('approve'),
        parameters: [web3.EthereumAddress.fromHex(approveToAddress), amount],
        gasPrice: web3.EtherAmount.inWei(gasPrice),
        maxGas: gasLimit,
        nonce: nonce,
        type: isAtlas ? MessageType.typeNormal : null,
      ),
      fetchChainIdFromNetworkId: true,
    );
    return bytesToHex(signed, include0x: true, padToEvenLength: true);
  }

  /// stakingAmount: how many amount of hyn do you what to stake.
  /// type:          what type of contract do you what to stake. [0 for 1 monty, 1 for 3 month, 2 for 6 month]
  Future<String> sendCreateMap3Node({
    BigInt stakingAmount,
    int type,
    String firstHalfPubKey,
    String secondHalfPubKey,
    String password,
    BigInt gasPrice,
    int gasLimit,
    int nonce,
  }) async {
    final client = WalletUtil.getWeb3Client();
    var credentials = await getCredentials(password);
    var map3Contract = WalletUtil.getMap3Contract(WalletConfig.map3ContractAddress);
    return await client.sendTransaction(
      credentials,
      web3.Transaction.callContract(
        contract: map3Contract,
        function: map3Contract.function('createNode'),
        parameters: [stakingAmount, BigInt.from(type), hexToBytes(firstHalfPubKey), hexToBytes(secondHalfPubKey)],
        gasPrice: web3.EtherAmount.inWei(gasPrice),
        maxGas: gasLimit,
        nonce: nonce,
      ),
      fetchChainIdFromNetworkId: true,
    );
  }

  Future<String> sendHynStakeWithdraw(
    HynContractMethod methodType,
    String password, {
        BigInt stakingAmount,
        BigInt gasPrice,
    int gasLimit,
  }) async {
    if (gasPrice == null) {
      gasPrice = BigInt.from(1 * TokenUnit.G_WEI);
    }
    if (gasLimit == null) {
      gasLimit = 300000;
    }
    if(!HYNApi.isGasFeeEnough(gasPrice, gasLimit, stakingAmount: stakingAmount)){
      return null;
    }

    var methodName = methodType == HynContractMethod.STAKE ? 'stake' : 'withdraw';

    final client = WalletUtil.getWeb3Client(true);
    var credentials = await getCredentials(password);
    var stakingContract = WalletUtil.getHynStakingContract(WalletConfig.hynStakingContractAddress);
    return await client.sendTransaction(
      credentials,
      web3.Transaction.callContract(
          value: stakingAmount != null ? EtherAmount.inWei(stakingAmount) : null,
          contract: stakingContract,
          function: stakingContract.function(methodName),
          parameters: [],
          gasPrice: web3.EtherAmount.inWei(gasPrice),
          maxGas: gasLimit,
          type: web3.MessageType.typeNormal),
      fetchChainIdFromNetworkId: false,
    );
  }

  Future<String> sendRpHolding(
      RpHoldingMethod methodType,
      String password, {
        BigInt depositAmount,
        BigInt burningAmount,
        BigInt withdrawAmount,
        BigInt gasPrice,
        int gasLimit,
      }) async {


    if (gasPrice == null) {
      gasPrice = BigInt.from(1 * TokenUnit.G_WEI);
    }
    if (gasLimit == null) {
      gasLimit = 300000;
    }
    BigInt stakingAmount;
    if(!HYNApi.isGasFeeEnough(gasPrice, gasLimit, stakingAmount: stakingAmount)){
      return null;
    }

    String methodName;
    List<dynamic> parameters;

    if (methodType == RpHoldingMethod.DEPOSIT_BURN) {
      methodName = 'depositAndBurn';
      parameters = [depositAmount, burningAmount];
    } else {
      methodName = 'withdraw';
      parameters = [withdrawAmount];
    }

    final client = WalletUtil.getWeb3Client(true);
    var credentials = await getCredentials(password);
    var rpHoldingContract = WalletUtil.getRpHoldingContract(WalletConfig.rpHoldingContractAddress);
    return await client.sendTransaction(
      credentials,
      web3.Transaction.callContract(
          contract: rpHoldingContract,
          function: rpHoldingContract.function(methodName),
          parameters: parameters,
          gasPrice: web3.EtherAmount.inWei(gasPrice),
          maxGas: gasLimit,
          type: web3.MessageType.typeNormal),
      fetchChainIdFromNetworkId: false,
    );
  }

  Future<String> signRpHolding(
      RpHoldingMethod methodType,
      String password, {
        BigInt depositAmount,
        BigInt burningAmount,
        BigInt withdrawAmount,
        BigInt gasPrice,
        int gasLimit,
        int nonce,
      }) async {


    if (gasPrice == null) {
      gasPrice = BigInt.from(1 * TokenUnit.G_WEI);
    }
    if (gasLimit == null) {
      gasLimit = 300000;
    }
    BigInt stakingAmount;
    if(!HYNApi.isGasFeeEnough(gasPrice, gasLimit, stakingAmount: stakingAmount)){
      throw HttpResponseCodeNotSuccess(-30011, 'HYN余额不足支付网络费用!');
    }

    String methodName;
    List<dynamic> parameters;

    if (methodType == RpHoldingMethod.DEPOSIT_BURN) {
      methodName = 'depositAndBurn';
      parameters = [depositAmount, burningAmount];
    } else {
      methodName = 'withdraw';
      parameters = [withdrawAmount];
    }

    final client = WalletUtil.getWeb3Client(true);
    var credentials = await getCredentials(password);
    var rpHoldingContract = WalletUtil.getRpHoldingContract(WalletConfig.rpHoldingContractAddress);
    var signedRaw = await client.signTransaction(
      credentials,
      web3.Transaction.callContract(
          contract: rpHoldingContract,
          function: rpHoldingContract.function(methodName),
          parameters: parameters,
          gasPrice: web3.EtherAmount.inWei(gasPrice),
          maxGas: gasLimit,
          nonce: nonce,
          type: web3.MessageType.typeNormal),
      fetchChainIdFromNetworkId: false,
    );
    return bytesToHex(signedRaw, include0x: true, padToEvenLength: true);
  }

  /// stakingAmount: how many amount of hyn do you what to stake.
  /// type:          what type of contract do you what to stake. [0 for 1 monty, 1 for 3 month, 2 for 6 month]
  Future<String> signCreateMap3Node({
    BigInt stakingAmount,
    int type,
    String firstHalfPubKey,
    String secondHalfPubKey,
    String password,
    BigInt gasPrice,
    int gasLimit,
    int nonce,
  }) async {
    final client = WalletUtil.getWeb3Client();
    var credentials = await getCredentials(password);
    var map3Contract = WalletUtil.getMap3Contract(WalletConfig.map3ContractAddress);
    var signed = await client.signTransaction(
      credentials,
      web3.Transaction.callContract(
        contract: map3Contract,
        function: map3Contract.function('createNode'),
        parameters: [stakingAmount, BigInt.from(type), hexToBytes(firstHalfPubKey), hexToBytes(secondHalfPubKey)],
        gasPrice: web3.EtherAmount.inWei(gasPrice),
        maxGas: gasLimit,
        nonce: nonce,
      ),
      fetchChainIdFromNetworkId: true,
    );
    return bytesToHex(signed, include0x: true, padToEvenLength: true);
  }

  Future<String> sendDelegateMap3Node({
    String createNodeWalletAddress,
    BigInt stakingAmount,
    String password,
    BigInt gasPrice,
    int gasLimit,
    int nonce,
  }) async {
    final client = WalletUtil.getWeb3Client();
    var credentials = await getCredentials(password);
    var map3Contract = WalletUtil.getMap3Contract(WalletConfig.map3ContractAddress);
    final txHash = await client.sendTransaction(
      credentials,
      web3.Transaction.callContract(
        contract: map3Contract,
        function: map3Contract.function('delegate'),
        parameters: [web3.EthereumAddress.fromHex(createNodeWalletAddress), stakingAmount],
        gasPrice: web3.EtherAmount.inWei(gasPrice),
        maxGas: gasLimit,
        nonce: nonce,
      ),
      fetchChainIdFromNetworkId: true,
    );

//    await transactionInteractor.insertTransactionDB(txHash, createNodeWalletAddress, stakingAmount, gasPrice,
//        gasLimit, LocalTransferType.LOCAL_TRANSFER_MAP3, nonce, contractAddress: "");
    return txHash;
  }

  Future<String> signDelegateMap3Node({
    String createNodeWalletAddress,
    BigInt stakingAmount,
    String password,
    BigInt gasPrice,
    int gasLimit,
    int nonce,
  }) async {
    final client = WalletUtil.getWeb3Client();
    var credentials = await getCredentials(password);
    var map3Contract = WalletUtil.getMap3Contract(WalletConfig.map3ContractAddress);
    var signed = await client.signTransaction(
      credentials,
      web3.Transaction.callContract(
        contract: map3Contract,
        function: map3Contract.function('delegate'),
        parameters: [web3.EthereumAddress.fromHex(createNodeWalletAddress), stakingAmount],
        gasPrice: web3.EtherAmount.inWei(gasPrice),
        maxGas: gasLimit,
        nonce: nonce,
      ),
      fetchChainIdFromNetworkId: true,
    );
    return bytesToHex(signed, include0x: true, padToEvenLength: true);
  }

  ///Withdraw token
  Future<String> sendCollectMap3Node({
    String createNodeWalletAddress,
    String password,
    BigInt gasPrice,
    int gasLimit,
    int nonce,
  }) async {
    final client = WalletUtil.getWeb3Client();
    var credentials = await getCredentials(password);
    var map3Contract = WalletUtil.getMap3Contract(WalletConfig.map3ContractAddress);
    var txHash = await client.sendTransaction(
      credentials,
      web3.Transaction.callContract(
        contract: map3Contract,
        function: map3Contract.function('collect'),
        parameters: [web3.EthereumAddress.fromHex(createNodeWalletAddress)],
        gasPrice: web3.EtherAmount.inWei(gasPrice),
        maxGas: gasLimit,
        nonce: nonce,
      ),
      fetchChainIdFromNetworkId: true,
    );

//    await transactionInteractor.insertTransactionDB(txHash, createNodeWalletAddress, BigInt.parse("0"), gasPrice,
//        gasLimit, LocalTransferType.LOCAL_TRANSFER_MAP3, nonce, contractAddress: "");
    return txHash;
  }

  ///Withdraw token
  Future<String> signCollectMap3Node({
    String createNodeWalletAddress,
    String password,
    BigInt gasPrice,
    int gasLimit,
    int nonce,
  }) async {
    final client = WalletUtil.getWeb3Client();
    var credentials = await getCredentials(password);
    var map3Contract = WalletUtil.getMap3Contract(WalletConfig.map3ContractAddress);
    var signed = await client.signTransaction(
      credentials,
      web3.Transaction.callContract(
        contract: map3Contract,
        function: map3Contract.function('collect'),
        parameters: [web3.EthereumAddress.fromHex(createNodeWalletAddress)],
        gasPrice: web3.EtherAmount.inWei(gasPrice),
        maxGas: gasLimit,
        nonce: nonce,
      ),
      fetchChainIdFromNetworkId: true,
    );
    return bytesToHex(signed, include0x: true, padToEvenLength: true);
  }

  Future<bool> delete(String password) async {
    return WalletChannel.delete(keystore.fileName, password);
  }

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);

  Map<String, dynamic> toJson() => _$WalletToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum HynContractMethod { STAKE, WITHDRAW }


enum RpHoldingMethod { DEPOSIT_BURN, WITHDRAW }
