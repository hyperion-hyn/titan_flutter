import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/setting/system_config_entity.dart';
import 'package:titan/src/components/wallet/vo/wallet_view_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/domain/transaction_interactor.dart';
import 'package:titan/src/pages/wallet/api/bitcoin_api.dart';
import 'package:titan/src/pages/wallet/api/hyn_api.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/config/ethereum.dart';
import 'package:titan/src/plugins/wallet/config/heco.dart';
import 'package:titan/src/plugins/wallet/config/hyperion.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet_channel.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:web3dart/web3dart.dart';

import 'wallet_expand_info_entity.dart';
import 'wallet_util.dart';

part 'wallet.g.dart';

@JsonSerializable()
class Wallet {
  ///activated account of this wallet,  btc, eth etc.
  List<Account> accounts;
  KeyStore keystore;

  WalletExpandInfoEntity walletExpandInfoEntity;

  Wallet({this.keystore, this.accounts, this.walletExpandInfoEntity});

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

  String getHeadImg() {
    /*if ((walletExpandInfoEntity?.localHeadImg ?? "").isNotEmpty) {
      return walletExpandInfoEntity.localHeadImg;
    }*/
    if ((walletExpandInfoEntity?.netHeadImg ?? "").isNotEmpty) {
      return walletExpandInfoEntity.netHeadImg;
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

  Future<BigInt> getBalanceByCoinTypeAndAddress(int coinType, String address,
      [String contractAddress, String block = 'latest']) async {
    return WalletUtil.getBalanceByCoinTypeAndAddress(coinType, address, contractAddress, block);
  }

  ///get balance of account
  ///@param block: an integer block number, or the string "latest", "earliest" or "pending"
  Future<BigInt> getBalance(Account account, [dynamic block = 'latest']) async {
    if (account != null) {
      return getBalanceByCoinTypeAndAddress(account.coinType, account.address);
    }
    return BigInt.from(0);
  }

  Future<BigInt> getErc20Balance(Account account, String erc20ContractAddress) async {
    if (account != null) {
      return getBalanceByCoinTypeAndAddress(
          account.coinType, account.address, erc20ContractAddress);
    }
    return BigInt.from(0);
  }

  Future<BigInt> getAllowance(
    String contractAddress,
    String ownAddress,
    String approveToAddress,
    int coinType,
  ) async {
    final contract = WalletUtil.getErc20Contract(contractAddress, 'HYN');
    final balanceFun = contract.function('allowance');
    final allowance = await WalletUtil.getWeb3Client(coinType).call(
        contract: contract,
        function: balanceFun,
        params: [
          web3.EthereumAddress.fromHex(ownAddress),
          web3.EthereumAddress.fromHex(approveToAddress)
        ]);
    return allowance.first;
  }

  Future<BigInt> getBitcoinBalance(String pubString) async {
    var response = await BitcoinApi.requestBitcoinBalance(pubString);
    if (response != null && response['code'] == 0) {
      return BigInt.from(response['data']);
    }
    return BigInt.from(0);
  }

  /// https://infura.io/docs/ethereum#operation/eth_estimateGas
  Future<BigInt> estimateGasPrice(
    int coinType, {
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
      // if (gasPrice == null) {
      //   gasPrice = BigInt.from(EthereumGasPrice.FAST_SPEED);
      // }
      var params = {};
      params['gas'] = '0x${gasLimit.toRadixString(16)}';
      params['from'] = account.address;
      if (toAddress != null) {
        params['to'] = toAddress;
      }
      if (gasPrice != null) {
        params['gasPrice'] = '0x${gasPrice.toRadixString(16)}';
      }
      if (value != null) {
        params['value'] = '0x${value.toRadixString(16)}';
      }
      if (data != null) {
        params['data'] = data;
      }
      var response = await WalletUtil.postToEthereumNetwork(coinType,
          method: 'eth_estimateGas', params: [params]);
      if (response['result'] != null) {
        BigInt amountUsed = hexToInt(response['result']);
//        return amountUsed * gasPrice;
        return amountUsed;
      }
    }

    return BigInt.from(0);
  }

  Future<int> getCurrentWalletNonce(int coinType,
      {int nonce, BlockNum atBlock: const BlockNum.pending()}) async {
    if (nonce == null) {
      var coinVo = WalletInheritedModel.of(Keys.rootKey.currentContext).getBaseCoinVo(coinType);
      String fromAddress = coinVo?.address;
      if (fromAddress != null && fromAddress.isNotEmpty) {
        nonce = await WalletUtil.getWeb3Client(coinType)
            .getTransactionCount(EthereumAddress.fromHex(fromAddress), atBlock: atBlock);
      }
    }
    return nonce;
  }

  /// 发送转账
  /// 如果[type]设置为 web3.MessageType.typeNormal 则是 Atlas转账
  /// 如果[message]设置了，则为抵押相关的操作
  /// 如果[type]和[message]都是null，则为ethereum转账
  Future<String> sendTransaction(
    int coinType, {
    String password,
    Credentials cred,
    @required BigInt gasPrice,
    String toAddress,
    BigInt value,
    int nonce,
    int gasLimit,
    web3.IMessage message,
    int optType = OptType.TRANSFER,
  }) async {
    nonce = await getCurrentWalletNonce(coinType, nonce: nonce);

    // 检查基础币是否足够
    if (gasLimit == null || gasLimit < 21000) {
      if (message != null) {
        gasLimit = HyperionGasLimit.NODE_OPT;
      } else {
        gasLimit = SettingInheritedModel.ofConfig(Keys.rootKey.currentContext)
            .systemConfigEntity
            .ethTransferGasLimit;
      }
    }

    final signedRawHex = await signTransaction(
      coinType,
      password: password,
      cred: cred,
      toAddress: toAddress,
      gasPrice: gasPrice,
      value: value,
      message: message,
      gasLimit: gasLimit,
      nonce: nonce,
    );

    var responseMap = await WalletUtil.postToEthereumNetwork(coinType,
        method: 'eth_sendRawTransaction', params: [signedRawHex]);
    if (responseMap['error'] != null) {
      var errorEntity = responseMap['error'];
      throw RPCError(errorEntity['code'], errorEntity['message'], "");
    } else if (responseMap['result'] != null) {
      // 本地记录ethereum pending
      if (coinType == CoinType.ETHEREUM) {
        await Injector.of(Keys.rootKey.currentContext).transactionInteractor.insertTransactionDB(
            responseMap['result'],
            toAddress,
            value,
            gasPrice,
            gasLimit,
            LocalTransferType.LOCAL_TRANSFER_ETH,
            nonce,
            optType: optType);
      }
    }

    return responseMap['result'];
  }

  /// 签名转账
  /// 如果[type]设置为 web3.MessageType.typeNormal 则是 Atlas转账
  /// 如果[message]设置了，则为抵押相关的操作
  /// 如果[type]和[message]都是null，则为ethereum转账
  Future<String> signTransaction(
    int coinType, {
    String password,
    Credentials cred,
    BigInt gasPrice,
    BigInt value,
    String toAddress,
    int nonce,
    int gasLimit,
    web3.IMessage message,
    Uint8List data,
  }) async {
    // assert(password == null && cred == null, '密码/密钥不能为空');
    assert(password == null || cred == null, S.of(Keys.rootKey.currentContext).pwd_or_private_key_can_not_be_empty);

    if (gasPrice == null) {
      gasPrice = await WalletUtil.ethGasPrice(coinType);
    }

    // 检查基础币是否足够
    if (gasLimit == null || gasLimit < 21000) {
      if (message?.type != null) {
        //节点操作
        gasLimit = HyperionGasLimit.NODE_OPT;
      } else {
        // 普通转账
        gasLimit = SettingInheritedModel.ofConfig(Keys.rootKey.currentContext)
            .systemConfigEntity
            .ethTransferGasLimit;
      }
    }
    var baseCoinVo = WalletInheritedModel.of(Keys.rootKey.currentContext)?.getBaseCoinVo(coinType);
    var balance = baseCoinVo?.balance;
    if (balance == null) {
      throw Exception('check balance fail');
    }

    var gasLimitBigInt = BigInt.from(gasLimit);
    var gasFees = gasLimitBigInt * gasPrice;
    // print(
    //     "gasLimit:${gasLimit.runtimeType}, value:${value.runtimeType}, gasFees:${gasFees.runtimeType}, balance:${balance.runtimeType}");

    if (value != null) {
      if ((gasFees + value) > balance) {
        throw Exception(S.of(Keys.rootKey.currentContext).transaction_amount_over_than_balance);
      }
    }

    var type = message?.type;
    if (type == null && coinType == CoinType.HYN_ATLAS) {
      type = MessageType.typeNormal;
    }

    //var privateKey = await WalletUtil.exportPrivateKey(fileName: keystore.fileName, password: password);

    final client = WalletUtil.getWeb3Client(coinType);
    var credentials = cred;
    if (credentials == null) {
      var privateKey =
          await WalletUtil.exportPrivateKey(fileName: keystore.fileName, password: password);
      credentials = await client.credentialsFromPrivateKey(privateKey);
    }
    var chainId = _getChainId(coinType);
    final rawTx = await client.signTransaction(
      credentials,
      web3.Transaction(
        to: toAddress == null ? null : web3.EthereumAddress.fromHex(toAddress),
        gasPrice: gasPrice != null ? web3.EtherAmount.inWei(gasPrice) : null,
        maxGas: gasLimit,
        value: value == null ? null : web3.EtherAmount.inWei(value),
        nonce: nonce,
        type: type,
        message: message,
        data: data,
      ),
      chainId: chainId,
      fetchChainIdFromNetworkId: chainId == null,
    );

    return bytesToHex(rawTx, include0x: true, padToEvenLength: true);
  }

  int _getChainId(int coinType) {
    if (coinType == CoinType.HYN_ATLAS) {
      return HyperionRpcProvider.chainId;
    } else if (coinType == CoinType.ETHEREUM) {
      return EthereumRpcProvider.chainId;
    } else if (coinType == CoinType.HB_HT) {
      return HecoRpcProvider.chainId;
    }
    return null;
  }

  Future<String> sendErc20Transaction(
    int coinType, {
    int optType = OptType.TRANSFER,
    @required String contractAddress,
    String password,
    Credentials cred,
    @required String toAddress,
    @required BigInt value,
    BigInt gasPrice,
    int nonce,
    int gasLimit,
  }) async {
    nonce = await getCurrentWalletNonce(coinType, nonce: nonce);

    // 检查基础币是否足够
    if (gasLimit == null || gasLimit < 21000) {
      gasLimit = SettingInheritedModel.ofConfig(Keys.rootKey.currentContext)
          .systemConfigEntity
          .erc20TransferGasLimit;
    }

    var signedRawHex = await signErc20Transaction(
      coinType,
      contractAddress: contractAddress,
      password: password,
      cred: cred,
      toAddress: toAddress,
      value: value,
      gasLimit: gasLimit,
      gasPrice: gasPrice != null ? gasPrice : null,
      nonce: nonce,
    );

    var responseMap = await WalletUtil.postToEthereumNetwork(coinType,
        method: 'eth_sendRawTransaction', params: [signedRawHex]);
    if (responseMap['error'] != null) {
      var errorEntity = responseMap['error'];
      throw RPCError(errorEntity['code'], errorEntity['message'], "");
    } else if (responseMap['result'] != null) {
      // 本地记录ethereum erc20 pending
      if (coinType == CoinType.ETHEREUM) {
        await Injector.of(Keys.rootKey.currentContext).transactionInteractor.insertTransactionDB(
            responseMap['result'],
            toAddress,
            value,
            gasPrice,
            gasLimit,
            LocalTransferType.LOCAL_TRANSFER_ERC20,
            nonce,
            optType: optType,
            contractAddress: contractAddress);
      }
    }

    return responseMap['result'];
  }

  Future<String> signErc20Transaction(
    int coinType, {
    @required String contractAddress,
    String password,
    Credentials cred,
    @required String toAddress,
    @required BigInt value,
    BigInt gasPrice,
    int nonce,
    int gasLimit,
  }) async {
    assert(contractAddress != null, S.of(Keys.rootKey.currentContext).contract_address_can_not_be_empty);
    assert((password == null || cred == null), );
    assert(toAddress != null, S.of(Keys.rootKey.currentContext).receiver_can_not_be_empty);
    assert(value != null, S.of(Keys.rootKey.currentContext).transaction_amount_can_not_be_empty);

    if (gasPrice == null) {
      gasPrice = await WalletUtil.ethGasPrice(coinType);
    }

    // 检查基础币是否足够
    if (gasLimit == null || gasLimit < 21000) {
      gasLimit = SettingInheritedModel.ofConfig(Keys.rootKey.currentContext)
          .systemConfigEntity
          .erc20TransferGasLimit;
    }
    var baseCoinVo = WalletInheritedModel.of(Keys.rootKey.currentContext)?.getBaseCoinVo(coinType);
    var balance = baseCoinVo?.balance;
    if (balance == null) {
      throw Exception('check balance fail');
    }
    var gasFees = BigInt.from(gasLimit) * gasPrice;
    if (gasFees > balance) {
      throw Exception('${baseCoinVo.symbol}${S.of(Keys.rootKey.currentContext).balance_not_enough_for_network_fee}');
    }

    final client = WalletUtil.getWeb3Client(coinType);
    var credentials = cred;
    if (credentials == null) {
      var privateKey =
          await WalletUtil.exportPrivateKey(fileName: keystore.fileName, password: password);
      credentials = await client.credentialsFromPrivateKey(privateKey);
    }
    final contract = WalletUtil.getErc20Contract(contractAddress, 'HYN');

    var chainId = _getChainId(coinType);

    final rawTx = await client.signTransaction(
      credentials,
      web3.Transaction.callContract(
        contract: contract,
        function: contract.function('transfer'),
        parameters: [web3.EthereumAddress.fromHex(toAddress), value],
        gasPrice: gasPrice != null ? web3.EtherAmount.inWei(gasPrice) : null,
        maxGas: gasLimit,
        nonce: nonce,
        type: coinType == CoinType.HYN_ATLAS ? MessageType.typeNormal : null,
      ),
      chainId: chainId,
      fetchChainIdFromNetworkId: chainId == null,
    );
    return bytesToHex(rawTx, include0x: true, padToEvenLength: true);
  }

  /*Future<String> signHYNHrc30Transaction({
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
      Fluttertoast.showToast(msg: S.of(Keys.rootKey.currentContext).hyn_balance_not_enough_gas);
      return null;
    }

    var privateKey = await WalletUtil.exportPrivateKey(fileName: keystore.fileName, password: password);
    final client = WalletUtil.getWeb3Client(true);
    final credentials = await client.credentialsFromPrivateKey(privateKey);
    final contract = WalletUtil.getHynErc20Contract(contractAddress);
    final rawTx = await client.signTransaction(
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

    if (rawTx == null) {
      Fluttertoast.showToast(msg: S.of(Keys.rootKey.currentContext).broadcast_exception);
    }
    return bytesToHex(rawTx, include0x: true, padToEvenLength: true);
  }*/

  Future<dynamic> sendBitcoinTransaction(
      String password, String pubString, String toAddr, int fee, int amount) async {
    var transResult = await BitcoinApi.sendBitcoinTransaction(
        keystore.fileName, password, pubString, toAddr, fee, amount);
    return transResult;
  }

  Future<String> bitcoinActive(String password) async {
    var result = await TitanPlugin.bitcoinActive(keystore.fileName, password);
    return result;
  }

  Future<web3.Credentials> getCredentials(int coinType, String password) async {
    var privateKey =
        await WalletUtil.exportPrivateKey(fileName: keystore.fileName, password: password);
    final client = WalletUtil.getWeb3Client(coinType);
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
    int coinType,
  }) async {
    final client = WalletUtil.getWeb3Client(coinType);
    var credentials = await getCredentials(coinType, password);
    var erc20Contract = WalletUtil.getErc20Contract(contractAddress, 'HYN');
    var chainId = _getChainId(coinType);
    final txHash = await client.sendTransaction(
      credentials,
      web3.Transaction.callContract(
        contract: erc20Contract,
        function: erc20Contract.function('approve'),
        parameters: [web3.EthereumAddress.fromHex(approveToAddress), amount],
        gasPrice: web3.EtherAmount.inWei(gasPrice),
        maxGas: gasLimit,
        nonce: nonce,
        type: coinType == CoinType.HYN_ATLAS ? MessageType.typeNormal : null,
      ),
      chainId: chainId,
      fetchChainIdFromNetworkId: chainId == null,
    );
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
    int coinType,
  }) async {
    final client = WalletUtil.getWeb3Client(coinType);
    var credentials = await getCredentials(coinType, password);
    var erc20Contract = WalletUtil.getErc20Contract(contractAddress, 'HYN');
    var chainId = _getChainId(coinType);
    var signed = await client.signTransaction(
      credentials,
      web3.Transaction.callContract(
        contract: erc20Contract,
        function: erc20Contract.function('approve'),
        parameters: [web3.EthereumAddress.fromHex(approveToAddress), amount],
        gasPrice: web3.EtherAmount.inWei(gasPrice),
        maxGas: gasLimit,
        nonce: nonce,
        type: coinType == CoinType.HYN_ATLAS ? MessageType.typeNormal : null,
      ),
      chainId: chainId,
      fetchChainIdFromNetworkId: chainId == null,
    );
    return bytesToHex(signed, include0x: true, padToEvenLength: true);
  }

  Future<String> sendHynStakeWithdraw(
    HynContractMethod methodType,
    String password, {
    BigInt stakingAmount,
    BigInt gasPrice,
    int gasLimit,
  }) async {
    if (gasPrice == null) {
      gasPrice = BigInt.from(1 * EthereumUnitValue.G_WEI);
    }
    if (gasLimit == null) {
      gasLimit = HyperionGasLimit.HRC30_APPROVE_RP;
    }
    if (!HYNApi.isGasFeeEnough(gasPrice, gasLimit, stakingAmount: stakingAmount)) {
      return null;
    }

    var methodName = methodType == HynContractMethod.STAKE ? 'stake' : 'withdraw';

    var coinType = CoinType.HYN_ATLAS;
    final client = WalletUtil.getWeb3Client(coinType);
    var credentials = await getCredentials(coinType, password);
    var stakingContract =
        WalletUtil.getHynStakingContract(HyperionConfig.hynStakingContractAddress);
    return await client.sendTransaction(
      credentials,
      web3.Transaction.callContract(
        value: stakingAmount != null ? EtherAmount.inWei(stakingAmount) : null,
        contract: stakingContract,
        function: stakingContract.function(methodName),
        parameters: [],
        gasPrice: web3.EtherAmount.inWei(gasPrice),
        maxGas: gasLimit,
        type: web3.MessageType.typeNormal,
      ),
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
      gasPrice = BigInt.from(1 * EthereumUnitValue.G_WEI);
    }
    if (gasLimit == null) {
      gasLimit = 300000;
    }
    BigInt stakingAmount;
    if (!HYNApi.isGasFeeEnough(gasPrice, gasLimit, stakingAmount: stakingAmount)) {
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

    var coinType = CoinType.HYN_ATLAS;
    final client = WalletUtil.getWeb3Client(coinType);
    var credentials = await getCredentials(coinType, password);
    var rpHoldingContract =
        WalletUtil.getRpHoldingContract(HyperionConfig.rpHoldingContractAddress);
    return await client.sendTransaction(
      credentials,
      web3.Transaction.callContract(
        contract: rpHoldingContract,
        function: rpHoldingContract.function(methodName),
        parameters: parameters,
        gasPrice: web3.EtherAmount.inWei(gasPrice),
        maxGas: gasLimit,
        type: web3.MessageType.typeNormal,
      ),
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
      gasPrice = BigInt.from(1 * EthereumUnitValue.G_WEI);
    }
    if (gasLimit == null) {
      gasLimit = 300000;
    }
    BigInt stakingAmount;
    if (!HYNApi.isGasFeeEnough(gasPrice, gasLimit, stakingAmount: stakingAmount)) {
      throw HttpResponseCodeNotSuccess(
          -30011, S.of(Keys.rootKey.currentContext).hyn_balance_not_enough_gas);
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

    var coinType = CoinType.HYN_ATLAS;
    final client = WalletUtil.getWeb3Client(coinType);
    var credentials = await getCredentials(coinType, password);
    var rpHoldingContract =
        WalletUtil.getRpHoldingContract(HyperionConfig.rpHoldingContractAddress);
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

  Future<bool> delete(String password) async {
    return WalletChannel.delete(keystore.fileName, password);
  }

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);

  Map<String, dynamic> toJson() => _$WalletToJson(this);

  Wallet copyWith([Wallet target]) {
    return Wallet(
      accounts: target?.accounts ?? this.accounts,
      keystore: target?.keystore ?? this.keystore,
      walletExpandInfoEntity: target?.walletExpandInfoEntity ?? this.walletExpandInfoEntity,
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

enum HynContractMethod { STAKE, WITHDRAW }

enum RpHoldingMethod { DEPOSIT_BURN, WITHDRAW }
