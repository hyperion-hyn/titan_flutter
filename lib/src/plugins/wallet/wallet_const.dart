import 'package:titan/config.dart';
import 'package:titan/src/plugins/wallet/contract_const.dart';
import 'package:titan/src/plugins/wallet/token.dart';

import '../../../env.dart';

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
  static const LOW_SPEED = 25 * TokenUnit.G_WEI;
  static const FAST_SPEED = 40 * TokenUnit.G_WEI;
  static const SUPER_FAST_SPEED = 70 * TokenUnit.G_WEI;

  static const int ETH_TRANSFER_GAS_LIMIT = 21000;
  static const int ERC20_TRANSFER_GAS_LIMIT = 65000;

  static const int ERC20_APPROVE_GAS_LIMIT = 50000;

  static const int CREATE_MAP3_NODE_GAS_LIMIT = 560000;
  static const int DELEGATE_MAP3_NODE_GAS_LIMIT = 700000;

  static const int COLLECT_MAP3_NODE_CREATOR_GAS_LIMIT_81 = 2800000;
  static const int COLLECT_MAP3_NODE_CREATOR_GAS_LIMIT_61 = 2100000;
  static const int COLLECT_MAP3_NODE_CREATOR_GAS_LIMIT_41 = 1500000;
  static const int COLLECT_MAP3_NODE_CREATOR_GAS_LIMIT_21 = 800000;

  static const int COLLECT_MAP3_NODE_CREATOR_GAS_LIMIT = 800000;

  static const int COLLECT_MAP3_NODE_PARTNER_GAS_LIMIT = 80000;
  static const int COLLECT_HALF_MAP3_NODE_GAS_LIMIT = 150000;
}

class BitcoinConst {
  static const BTC_LOW_SPEED = 15;
  static const BTC_FAST_SPEED = 30;
  static const BTC_SUPER_FAST_SPEED = 60;
  static const BTC_RAWTX_SIZE = 225;
}

class WalletError {
  static const UNKNOWN_ERROR = "0";
  static const PASSWORD_WRONG = "1";
  static const PARAMETERS_WRONG = "2";
}

enum EthereumNetType {
  main,
  ropsten,
  rinkeby,
  local,
}

enum BitcoinNetType {
  main,
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

  static String get INFURA_ROPSTEN_API => '${Config.INFURA_ROPSTEN_API_URL}/v3/${Config.INFURA_PRVKEY}';

  static String get INFURA_RINKEBY_API => 'https://rinkeby.infura.io/v3/${Config.INFURA_PRVKEY}';

  static String get BITCOIN_MAIN_API => 'https://api.wallet.hyn.space/wallet/btc/';

  static String get BITCOIN_LOCAL_API => 'https://api.wallet.hyn.space/wallet/btc/';

  static String get WALLET_ADDRESS_API => 'https://api.wallet.hyn.space/wallet/address';

  static String get ATLAS_API => Config.ATLAS_API;

  static String get ATLAS_API_TEST => Config.ATLAS_API_TEST;

//  static String get BITCOIN_LOCAL_API => 'http://10.10.1.134/wallet/btc/';

  static String get BITCOIN_TRANSATION_DETAIL => 'https://blockchair.com/bitcoin/transaction/';

  //todo: test_rp
  static EthereumNetType netType = env.buildType == BuildType.DEV ? EthereumNetType.ropsten : EthereumNetType.main;

  static BitcoinNetType bitcoinNetType = env.buildType == BuildType.DEV ? BitcoinNetType.local : BitcoinNetType.main;

  static clearNetType() {
     netType = env.buildType == BuildType.DEV ? EthereumNetType.ropsten : EthereumNetType.main;
    bitcoinNetType = env.buildType == BuildType.DEV ? BitcoinNetType.local : BitcoinNetType.main;
  }

  static String get map3ContractAddress {
    switch (netType) {
      case EthereumNetType.main:
        return '0x04dd43162ccb7c2e256128e28e29218c5057e7f3';
      case EthereumNetType.ropsten:
        return '0x2c6FA17BDF5Cb10e64d26bFc62f64183D9f939A6';
      case EthereumNetType.rinkeby:
        return '0x02061f896Da00fC459C05a6f864b479137Dcb34b';
      case EthereumNetType.local:
        return ContractTestConfig.map3ContractAddress;
      //return '0x14D135f91B01db0DF32cdcF7d7e93cc14A9aE3D7';
    }
    return '';
  }

  static String get getHynErc20Address {
    switch (netType) {
      case EthereumNetType.main:
        return SupportedTokens.HYN_ERC20.contractAddress;
      case EthereumNetType.ropsten:
        return SupportedTokens.HYN_ROPSTEN.contractAddress;
      case EthereumNetType.rinkeby:
        return SupportedTokens.HYN_RINKEBY.contractAddress;
      case EthereumNetType.local:
        return SupportedTokens.HYN_LOCAL.contractAddress;
    }
    return '';
  }

  static String get hynRPHrc30Address {
    switch (netType) {
      case EthereumNetType.main:
        return SupportedTokens.HYN_RP_HRC30.contractAddress;
      case EthereumNetType.ropsten:
        return SupportedTokens.HYN_RP_HRC30_ROPSTEN.contractAddress;
      case EthereumNetType.local:
        return SupportedTokens.HYN_RP_HRC30_LOCAL.contractAddress;
    }
    return '';
  }

  static String getUsdtErc20Address() {
    switch (netType) {
      case EthereumNetType.main:
        return SupportedTokens.USDT_ERC20.contractAddress;
      case EthereumNetType.ropsten:
        return SupportedTokens.USDT_ERC20_ROPSTEN.contractAddress;
      case EthereumNetType.rinkeby:
        //have not deployed
        return SupportedTokens.USDT_ERC20.contractAddress;
      case EthereumNetType.local:
        //have not deployed
        return SupportedTokens.USDT_ERC20.contractAddress;
    }
    return '';
  }

  static String get hynStakingContractAddress {
    switch (netType) {
      case EthereumNetType.main:
        return '0x6910E6F7fe7C8D5444E63F8285f5342FfC7FCA6b';
      case EthereumNetType.ropsten:
        return '0x193b8996843227D963eceF73F17F93cE61d02454';
      case EthereumNetType.local:
        return "0x2190490FEcA5D47290CFA4a762b1889718913319";
    }
    return '';
  }

  static String getEthereumApi() {
    switch (netType) {
      case EthereumNetType.main:
        return INFURA_MAIN_API;
      case EthereumNetType.ropsten:
        return INFURA_ROPSTEN_API;
      case EthereumNetType.rinkeby:
        return INFURA_RINKEBY_API;
      case EthereumNetType.local:
        return ContractTestConfig.walletLocalDomain;
      //return LOCAL_API;
    }
    return '';
  }

  static String getAtlasApi() {
    switch (netType) {
      case EthereumNetType.main:
        return ATLAS_API;
      case EthereumNetType.ropsten:
        return ATLAS_API_TEST;
        break;
      case EthereumNetType.rinkeby:
        return ATLAS_API_TEST;
        break;
      case EthereumNetType.local:
        return ATLAS_API_TEST;
        break;
    }
    return ATLAS_API;
  }

  static String getBitcoinApi() {
    switch (bitcoinNetType) {
      case BitcoinNetType.main:
        return BITCOIN_MAIN_API;
      case BitcoinNetType.local:
        return BITCOIN_LOCAL_API;
      //return LOCAL_API;
    }
    return '';
  }
}
