import 'package:titan/config.dart';
import 'package:titan/src/plugins/wallet/contract_const.dart';

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

  static const int ETH_TRANSFER_GAS_LIMIT = 21000;
  static const int ERC20_TRANSFER_GAS_LIMIT = 55000;

  static const int ERC20_APPROVE_GAS_LIMIT = 50000;

  static const int CREATE_MAP3_NODE_GAS_LIMIT = 560000;
  static const int DELEGATE_MAP3_NODE_GAS_LIMIT = 680000;
  static const int COLLECT_MAP3_NODE_CREATOR_GAS_LIMIT = 2800000;
  static const int COLLECT_MAP3_NODE_PARTNER_GAS_LIMIT = 68000;
  static const int COLLECT_HALF_MAP3_NODE_GAS_LIMIT = 150000;
}

class WalletError {
  static const UNKNOWN_ERROR = "0";
  static const PASSWORD_WRONG = "1";
  static const PARAMETERS_WRONG = "2";
}

enum EthereumNetType {
  main,
  repsten,
  rinkeby,
  local,
}

EthereumNetType getEthereumNetTypeFromString(String type) {
  for (var value in EthereumNetType.values) {
    if (value.toString() == type) {
      return value;
    }
  }
  return EthereumNetType.main;
}

class WalletConfig {
  static String get INFURA_MAIN_API => '${Config.INFURA_API_URL}/v3/${Config.INFURA_PRVKEY}';

  static String get INFURA_ROPSTEN_API => 'https://ropsten.infura.io/v3/${Config.INFURA_PRVKEY}';

  static String get INFURA_RINKEBY_API => 'https://rinkeby.infura.io/v3/${Config.INFURA_PRVKEY}';

  static EthereumNetType netType = EthereumNetType.main;

  static String get map3ContractAddress {
    switch (netType) {
      case EthereumNetType.main:
        //TODO
        return '';
      case EthereumNetType.repsten:
        return '0x498382ADfea3124B290696C54205b8a9B738A8e5';
      case EthereumNetType.rinkeby:
        return '0xda3df1c86e4976643bfa69b830afa48ef5857d58';
      case EthereumNetType.local:
        return ContractTestConfig.map3ContractAddress;
      //return '0x14D135f91B01db0DF32cdcF7d7e93cc14A9aE3D7';
    }
    return '';
  }

  static String getEthereumApi() {
    switch (netType) {
      case EthereumNetType.main:
        return INFURA_MAIN_API;
      case EthereumNetType.repsten:
        return INFURA_ROPSTEN_API;
      case EthereumNetType.rinkeby:
        return INFURA_RINKEBY_API;
      case EthereumNetType.local:
        return ContractTestConfig.walletLocalDomain;
      //return LOCAL_API;
    }
    return '';
  }
}
