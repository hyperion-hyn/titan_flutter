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
  static const int ERC20_TRANSFER_GAS_LIMIT = 40000;

  static const int ERC20_APPROVE_GAS_LIMIT = 100000;

  //TODO
  static const int CREATE_MAP3_NODE_GAS_LIMIT = 1000000;
  static const int DELEGATE_MAP3_NODE_GAS_LIMIT = 1000000;
  static const int COLLECT_MAP3_NODE_GAS_LIMIT = 1000000;
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
  return EthereumNetType.main;
}

class WalletConfig {
  static String get INFURA_MAIN_API => '${Config.INFURA_API_URL}/v3/${Config.INFURA_PRVKEY}';

  static String get INFURA_ROPSTEN_API => 'https://ropsten.infura.io/v3/${Config.INFURA_PRVKEY}';

//  static const String LOCAL_API = 'http://116.23.19.213:37545';
  static const String LOCAL_API = 'http://10.10.1.115:7545';

  static EthereumNetType netType = EthereumNetType.main;

  static String get map3ContractAddress {
    switch (netType) {
      case EthereumNetType.main:
        //TODO
        return '0x194205c8e943E8540Ea937fc940B09b3B155E10a';
      case EthereumNetType.repsten:
        //TODO
        return '0x194205c8e943E8540Ea937fc940B09b3B155E10a';
      case EthereumNetType.local:
        return ContractTestConfig.stakingContract;
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
      case EthereumNetType.local:
        return LOCAL_API;
    }
    return '';
  }
}
