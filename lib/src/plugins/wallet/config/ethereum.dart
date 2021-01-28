import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/plugins/wallet/config/tokens.dart';
import 'package:titan/src/plugins/wallet/token.dart';

import '../../../../config.dart';
import '../../../../env.dart';

class EthereumUnitValue {
  static const WEI = 1;
  static const K_WEI = 1000;
  static const M_WEI = 1000000;
  static const G_WEI = 1000000000;
  static const T_WEI = 1000000000000;
  static const P_WEI = 1000000000000000;
  static const ETHER = 1000000000000000000;
}

class EthereumGasLimit {
  static const int ETH_TRANSFER_GAS_LIMIT = 21000;
  static const int ERC20_TRANSFER_GAS_LIMIT = 60000;

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

class EthereumGasPrice {
  static const LOW_SPEED = 25 * EthereumUnitValue.G_WEI;
  static const FAST_SPEED = 40 * EthereumUnitValue.G_WEI;
  static const SUPER_FAST_SPEED = 70 * EthereumUnitValue.G_WEI;

  static GasPriceRecommend getRecommend() {
    return WalletInheritedModel.of(Keys.rootKey.currentContext).ethGasPriceRecommend;
  }
}

enum EthereumChainType {
  mainnet,
  ropsten,
  rinkeby,
  local,
}

class EthereumRpcProvider {
  static String get MAIN_API => '${Config.INFURA_API_URL}/v3/${Config.INFURA_PRVKEY}';

  static String get ROPSTEN_API => '${Config.INFURA_ROPSTEN_API_URL}/v3/${Config.INFURA_PRVKEY}';

  static String get RINKEBY_API => 'https://rinkeby.infura.io/v3/${Config.INFURA_PRVKEY}';

  static String get rpcUrl {
    switch (EthereumConfig.chainType) {
      case EthereumChainType.mainnet:
        return MAIN_API;
      case EthereumChainType.ropsten:
        return ROPSTEN_API;
      case EthereumChainType.rinkeby:
        return RINKEBY_API;
      case EthereumChainType.local:
        return 'http://10.10.1.120:8545';
    }
    return '';
  }

  /// chainId
  /// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-155.md
  static int get chainId {
    switch (EthereumConfig.chainType) {
      case EthereumChainType.mainnet:
        return 1;
      case EthereumChainType.ropsten:
        return 3;
      case EthereumChainType.rinkeby:
        return 4;
      case EthereumChainType.local:
        return 1;
    }
    return 1;
  }

  EthereumChainType getChainTypeFromString(String type) {
    for (var value in EthereumChainType.values) {
      if (value.toString() == type) {
        return value;
      }
    }
    return EthereumChainType.mainnet;
  }
}

class EthereumConfig {
  static EthereumChainType chainType =
      env.buildType == BuildType.DEV ? EthereumChainType.ropsten : EthereumChainType.mainnet;

  /// map3 ethereum contract
  static String get map3EthereumContractAddress {
    switch (chainType) {
      case EthereumChainType.mainnet:
        return '0x04dd43162ccb7c2e256128e28e29218c5057e7f3';
      case EthereumChainType.ropsten:
        return '0x2c6FA17BDF5Cb10e64d26bFc62f64183D9f939A6';
      case EthereumChainType.rinkeby:
        return '0x02061f896Da00fC459C05a6f864b479137Dcb34b';
      case EthereumChainType.local:
        return '0x2c6FA17BDF5Cb10e64d26bFc62f64183D9f939A6';
    }
    return '';
  }

  static String get getHynErc20Address {
    switch (chainType) {
      case EthereumChainType.mainnet:
        return DefaultTokenDefine.HYN_ERC20.contractAddress;
      case EthereumChainType.ropsten:
        return DefaultTokenDefine.HYN_ROPSTEN.contractAddress;
      case EthereumChainType.rinkeby:
        return DefaultTokenDefine.HYN_RINKEBY.contractAddress;
      case EthereumChainType.local:
        return DefaultTokenDefine.HYN_LOCAL.contractAddress;
    }
    return '';
  }

  /// usdt ethereum constract address
  static String getUsdtErc20Address() {
    switch (EthereumConfig.chainType) {
      case EthereumChainType.mainnet:
        return DefaultTokenDefine.USDT_ERC20.contractAddress;
      case EthereumChainType.ropsten:
        return DefaultTokenDefine.USDT_ERC20_ROPSTEN.contractAddress;
      case EthereumChainType.rinkeby:
        //have not deployed
        return DefaultTokenDefine.USDT_ERC20.contractAddress;
      case EthereumChainType.local:
        //have not deployed
        return DefaultTokenDefine.USDT_ERC20.contractAddress;
    }
    return '';
  }
}

class EthereumExplore {
  static String get etherScanApi {
    switch (EthereumConfig.chainType) {
      case EthereumChainType.mainnet:
        return Config.ETHERSCAN_API_URL;
      case EthereumChainType.ropsten:
        return Config.ETHERSCAN_API_URL_ROPSTEN;
      case EthereumChainType.rinkeby:
        return Config.ETHERSCAN_API_URL_RINKEBY;
      default:
        return Config.ETHERSCAN_API_URL;
    }
  }

  static String get etherScanWeb {
    var isChinaMainland =
        SettingInheritedModel.of(Keys.rootKey.currentContext).areaModel?.isChinaMainland ?? true == true;
    if (EthereumConfig.chainType == EthereumChainType.mainnet) {
      if (isChinaMainland) {
        return 'https://cn.etherscan.com';
      } else {
        return "https://etherscan.io";
      }
    } else if (EthereumConfig.chainType == EthereumChainType.ropsten) {
      return "https://ropsten.etherscan.io";
    } else if (EthereumConfig.chainType == EthereumChainType.rinkeby) {
      return "https://rinkeby.etherscan.io";
    }
    return '';
  }
}
