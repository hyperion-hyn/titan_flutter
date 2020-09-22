import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/setting/system_config_entity.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/domain/transaction_interactor.dart';
import 'package:titan/src/pages/wallet/api/bitcoin_api.dart';
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
import 'package:web3dart/web3dart.dart' as web3;

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
  ) async {
    final contract = WalletUtil.getHynErc20Contract(contractAddress);
    final balanceFun = contract.function('allowance');
    final allowance = await WalletUtil.getWeb3Client().call(
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
      String localNonce = await transactionInteractor.getTransactionDBNonce(fromAddress);
      if (localNonce != null && int.parse(localNonce) >= nonce) {
        nonce = int.parse(localNonce) + 1;
      }
    }
    print("!!!!!nonce = $nonce");
    return nonce;
  }

  Future<String> sendEthTransaction({
    int id,
    String password,
    String toAddress,
    BigInt value,
    BigInt gasPrice,
    int nonce,
    int gasLimit = 0,
  }) async {
    if (gasLimit == 0) {
      gasLimit = SettingInheritedModel.ofConfig(Keys.rootKey.currentContext).systemConfigEntity.ethTransferGasLimit;
    }
//    nonce = await getCurrentWalletNonce(nonce: nonce);

    var privateKey = await WalletUtil.exportPrivateKey(fileName: keystore.fileName, password: password);
    final client = WalletUtil.getWeb3Client();
    final credentials = await client.credentialsFromPrivateKey(privateKey);
    final txHash = await client.sendTransaction(
      credentials,
      web3.Transaction(
        to: web3.EthereumAddress.fromHex(toAddress),
        gasPrice: web3.EtherAmount.inWei(gasPrice),
        maxGas: gasLimit,
        value: web3.EtherAmount.inWei(value),
        nonce: nonce,
      ),
      fetchChainIdFromNetworkId: true,
    );

//    await transactionInteractor.insertTransactionDB(
//        txHash, toAddress, value, gasPrice, gasLimit, LocalTransferType.LOCAL_TRANSFER_ETH, nonce, id: id);

    return txHash;
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

//    await transactionInteractor.insertTransactionDB(
//        txHash, toAddress, value, gasPrice, gasLimit, LocalTransferType.LOCAL_TRANSFER_HYN_USDT, nonce,
//        id: id, contractAddress: contractAddress);
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
  }) async {
    final client = WalletUtil.getWeb3Client();
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
      ),
      fetchChainIdFromNetworkId: true,
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
  }) async {
    final client = WalletUtil.getWeb3Client();
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
