/*

Wallet Address: 0x7C52f69ce94a2F73BC4fd2fA9265D0ceab79c4e3
Private key: 5e960e6e5ee9f0eb84083aeb2c82e88d806e61884aefa62d85d2ce7bb3c757b0
Staking contract: 0xEf429f2F9C4AB4a0723dEf4C76A8b5499dEB7205
ERC20: 0x884845609ea5DC317FA74Ccc5bdEc161Ce58D357
IP: 219.137.207.27
port: 37545,
network_id: 5777
*/

import 'package:titan/src/plugins/wallet/wallet_const.dart';

class ContractTestConfig {
  static String get hynContractAddress {
    if (WalletConfig.netType == EthereumNetType.rinkeby) {
      return '0xd643dc5aa8caf34295ab3c4cd3c4cc9f6b322b5c';
    } else if (WalletConfig.netType == EthereumNetType.repsten) {
      return '0xb438de1880ee10342f17F52e3D8CAF85Ee0fFD8f';
    }
    return '0x884845609ea5DC317FA74Ccc5bdEc161Ce58D357';
  }

  static String get map3ContractAddress {
    if (WalletConfig.netType == EthereumNetType.rinkeby) {
      return '0xda3df1c86e4976643bfa69b830afa48ef5857d58';
    } else if (WalletConfig.netType == EthereumNetType.repsten) {
      return '0x498382ADfea3124B290696C54205b8a9B738A8e5';
    }
    return '0xEf429f2F9C4AB4a0723dEf4C76A8b5499dEB7205';
  }

  static String get privateKey {
    if (WalletConfig.netType == EthereumNetType.rinkeby || WalletConfig.netType == EthereumNetType.repsten) {
      return '0x45f413a1fccb81463e71be9d8a563b1b6d6b20633b657fe0a81826ab473902ba';
    }
    return '5e960e6e5ee9f0eb84083aeb2c82e88d8 06e61884aefa62d85d2ce7bb3c757b0';
  }

//  static const String walletLocalDomain = "http://219.137.207.27:37545";
  static const String walletLocalDomain = "http://10.10.1.115:7545";

//  static const String apiLocalDomain = "http://219.137.207.27:35000/";
//  static const String apiLocalDomain = "http://10.10.1.115:5000/";
  static const String apiLocalDomain = "https://staking.map3.network/";
}
