import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet_channel.dart';
import 'package:titan/config.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart' as web3;

import 'wallet_util.dart';

part 'wallet.g.dart';

class TokenUnit {
  static const WEI = 1;
  static const K_WEI = 1000;
  static const M_WEI = 1000000;
  static const G_WEI = 1000000000;
  static const T_WEI = 1000000000000;
  static const P_WEI = 1000000000000000;
  static const ETHER = 1000000000000000000;
}

class EthereumConst {
  static const LOW_SPEED = 3 * TokenUnit.G_WEI;
  static const FAST_SPEED = 10 * TokenUnit.G_WEI;
  static const SUPER_FAST_SPEED = 30 * TokenUnit.G_WEI;

  static const int ETH_GAS_LIMIT = 21000;
  static const int ERC20_GAS_LIMIT = 25000;
}

class WalletError {
  static const UNKNOWN_ERROR = "0";
  static const PASSWORD_WRONG = "1";
  static const PARAMETERS_WRONG = "2";
}

enum EthereumNetType {
  main,
  repsten,
  local,
}

EthereumNetType getEthereumNetTypeFromString(String type) {
  for (var value in EthereumNetType.values) {
    if (value.toString() == type) {
      return value;
    }
  }
}

class WalletConfig {
  static String get INFURA_MAIN_API => '${Config.INFURA_API_URL}/v3/${Config.INFURA_PRVKEY}';

  static String get INFURA_ROPSTEN_API => 'https://ropsten.infura.io/v3/${Config.INFURA_PRVKEY}';

  static const String LOCAL_API = 'http://10.10.1.115:7545';

  static EthereumNetType netType = EthereumNetType.main;

  static String get map3ContractAddress {
    switch (netType) {
      case EthereumNetType.main:
        //TODO
        return '';
      case EthereumNetType.repsten:
        //TODO
        return '';
      case EthereumNetType.local:
        return '0x194205c8e943E8540Ea937fc940B09b3B155E10a';
    }
    return '';
  }

  static String getEthereumApi() {
    switch (netType) {
      case EthereumNetType.main:
        return INFURA_MAIN_API;
      case EthereumNetType.repsten:
        return INFURA_ROPSTEN_API;
      case EthereumNetType.local:
        return LOCAL_API;
    }
    return '';
  }
}

@JsonSerializable()
class Wallet {
  ///activated account of this wallet,  btc, eth etc.
  List<Account> accounts;
  KeyStore keystore;

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
    switch (coinType) {
      case CoinType.ETHEREUM:
        if (contractAddress == null) {
          var response = await WalletUtil.postToEthereumNetwork(method: "eth_getBalance", params: [address, block]);
          if (response['result'] != null) {
            return hexToInt(response['result']);
          }
        } else {
          final contract = WalletUtil.getHynErc20Contract(contractAddress);
          final balanceFun = contract.function('balanceOf');
          final balance = await WalletUtil.getWeb3Client()
              .call(contract: contract, function: balanceFun, params: [web3.EthereumAddress.fromHex(address)]);
          return balance.first;
        }
        break;
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
    if (account != null) {
      if (gasLimit == null) {
        if (data == null) {
          gasLimit = BigInt.from(EthereumConst.ETH_GAS_LIMIT);
        } else {
          gasLimit = BigInt.from(EthereumConst.ERC20_GAS_LIMIT);
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

  Future<String> sendEthTransaction({
    String password,
    String toAddress,
    BigInt value,
    BigInt gasPrice,
  }) async {
    var privateKey = await WalletUtil.exportPrivateKey(fileName: keystore.fileName, password: password);
    final client = WalletUtil.getWeb3Client();
    final credentials = await client.credentialsFromPrivateKey(privateKey);
    final txHash = await client.sendTransaction(
      credentials,
      web3.Transaction(
        to: web3.EthereumAddress.fromHex(toAddress),
        gasPrice: web3.EtherAmount.inWei(gasPrice),
        maxGas: EthereumConst.ETH_GAS_LIMIT,
        value: web3.EtherAmount.inWei(value),
      ),
      fetchChainIdFromNetworkId: true,
    );
    return txHash;
  }

  Future<String> sendErc20Transaction({
    String contractAddress,
    String password,
    String toAddress,
    BigInt value,
    BigInt gasPrice,
  }) async {
    var privateKey = await WalletUtil.exportPrivateKey(fileName: keystore.fileName, password: password);
    final client = WalletUtil.getWeb3Client();
    final credentials = await client.credentialsFromPrivateKey(privateKey);
    final contract = WalletUtil.getHynErc20Contract(contractAddress);
    return await client.sendTransaction(
      credentials,
      web3.Transaction.callContract(
        contract: contract,
        function: contract.function('transfer'),
        parameters: [web3.EthereumAddress.fromHex(toAddress), value],
        gasPrice: web3.EtherAmount.inWei(gasPrice),
        maxGas: EthereumConst.ERC20_GAS_LIMIT,
      ),
      fetchChainIdFromNetworkId: true,
    );
  }

  Future<web3.Credentials> getCredentials(String password) async {
    var privateKey = await WalletUtil.exportPrivateKey(fileName: keystore.fileName, password: password);
    final client = WalletUtil.getWeb3Client();
    final credentials = await client.credentialsFromPrivateKey(privateKey);
    return credentials;
  }

  Future<String> signApproveErc20Token({
    String contractAddress,
    String approveToAddress,
    String password,
    BigInt amount,
    BigInt gasPrice,
    int gasLimit,
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
      ),
      fetchChainIdFromNetworkId: true,
    );
    return bytesToHex(signed, include0x: true, padToEvenLength: true);
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
      ),
      fetchChainIdFromNetworkId: true,
    );
    return bytesToHex(signed, include0x: true, padToEvenLength: true);
  }

  Future<String> signDelegateMap3Node({
    String createNodeWalletAddress,
    BigInt stakingAmount,
    String password,
    BigInt gasPrice,
    int gasLimit,
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
      ),
      fetchChainIdFromNetworkId: true,
    );
    return bytesToHex(signed, include0x: true, padToEvenLength: true);
  }

  ///Withdraw token
  Future<String> signCollectMap3Node({
    String createNodeWalletAddress,
    String password,
    BigInt gasPrice,
    int gasLimit,
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
