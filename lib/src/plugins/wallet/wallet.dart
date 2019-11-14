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

  static const ETH_GAS_LIMIT = 21000;
  static const ERC20_GAS_LIMIT = 60000;

  static const HYN_ERC20_ABI = '''
[
  {
    "constant": true,
    "inputs": [],
    "name": "name",
    "outputs": [
      {
        "name": "",
        "type": "string"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "_spender",
        "type": "address"
      },
      {
        "name": "_value",
        "type": "uint256"
      }
    ],
    "name": "approve",
    "outputs": [
      {
        "name": "",
        "type": "bool"
      }
    ],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "totalSupply",
    "outputs": [
      {
        "name": "",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "_from",
        "type": "address"
      },
      {
        "name": "_to",
        "type": "address"
      },
      {
        "name": "_value",
        "type": "uint256"
      }
    ],
    "name": "transferFrom",
    "outputs": [
      {
        "name": "",
        "type": "bool"
      }
    ],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "INITIAL_SUPPLY",
    "outputs": [
      {
        "name": "",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "decimals",
    "outputs": [
      {
        "name": "",
        "type": "uint8"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "_spender",
        "type": "address"
      },
      {
        "name": "_subtractedValue",
        "type": "uint256"
      }
    ],
    "name": "decreaseApproval",
    "outputs": [
      {
        "name": "",
        "type": "bool"
      }
    ],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "name": "_owner",
        "type": "address"
      }
    ],
    "name": "balanceOf",
    "outputs": [
      {
        "name": "",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "symbol",
    "outputs": [
      {
        "name": "",
        "type": "string"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "_to",
        "type": "address"
      },
      {
        "name": "_value",
        "type": "uint256"
      }
    ],
    "name": "transfer",
    "outputs": [

      {
        "name": "",
        "type": "bool"
      }
    ],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "_spender",
        "type": "address"
      },
      {
        "name": "_addedValue",
        "type": "uint256"
      }
    ],
    "name": "increaseApproval",
    "outputs": [
      {
        "name": "",
        "type": "bool"
      }
    ],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "name": "_owner",
        "type": "address"
      },
      {
        "name": "_spender",
        "type": "address"
      }
    ],
    "name": "allowance",
    "outputs": [
      {
        "name": "",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "name": "owner",
        "type": "address"
      },
      {
        "indexed": true,
        "name": "spender",
        "type": "address"
      },
      {
        "indexed": false,
        "name": "value",
        "type": "uint256"
      }
    ],
    "name": "Approval",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "name": "from",
        "type": "address"
      },
      {
        "indexed": true,
        "name": "to",
        "type": "address"
      },
      {
        "indexed": false,
        "name": "value",
        "type": "uint256"
      }
    ],
    "name": "Transfer",
    "type": "event"
  }
]
  ''';
}

class WalletConfig {
  static String get INFURA_MAIN_API => 'https://mainnet.infura.io/v3/${Config.INFURA_PRVKEY}';

  static String get INFURA_ROPSTEN_API => 'https://ropsten.infura.io/v3/${Config.INFURA_PRVKEY}';

  static bool isMainNet = true;

  static String getInfuraApi() {
    return isMainNet ? INFURA_MAIN_API : INFURA_ROPSTEN_API;
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
      final contract = WalletUtil.getHynErc20Contract(contractAddress);
      final balanceFun = contract.function('balanceOf');
      final balance = await WalletUtil.getWeb3Client()
          .call(contract: contract, function: balanceFun, params: [web3.EthereumAddress.fromHex(account.address)]);
      return balance.first;
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
  ///black: an integer block number, or the string "latest", "earliest" or "pending"
  Future<BigInt> getBalance(Account account, [dynamic block = 'latest']) async {
    if (account != null) {
      switch (account.coinType) {
        case CoinType.ETHEREUM:
          var response = await WalletUtil.postInfura(method: "eth_getBalance", params: [account.address, block]);
          if (response['result'] != null) {
            return hexToInt(response['result']);
          }
          break;
      }
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
      var response = await WalletUtil.postInfura(method: 'eth_estimateGas', params: [params]);
      if (response['result'] != null) {
        BigInt amountUsed = hexToInt(response['result']);
        return amountUsed * gasPrice;
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

  Future<bool> delete(String password) async {
    return WalletChannel.delete(keystore.fileName, password);
  }

  factory Wallet.fromJson(Map<String, dynamic> json) => _$TrustWalletFromJson(json);

  Map<String, dynamic> toJson() => _$TrustWalletToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
