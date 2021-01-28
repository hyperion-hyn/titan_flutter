import 'package:titan/config.dart';
import 'package:titan/env.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/plugins/wallet/config/tokens.dart';
import 'package:titan/src/plugins/wallet/token.dart';

class HyperionUnitValue {
  static const DUST = 1;
  static const K_DUST = 1000;
  static const M_DUST = 1000000;
  static const G_DUST = 1000000000;
  static const T_DUST = 1000000000000;
  static const P_DUST = 1000000000000000;
  static const HYN = 1000000000000000000;
}

class HyperionGasLimit {
  static const int TRANSFER = 21000;
  static const int NODE_OPT = 100000;
  static const int HRC30_TRANSFER = 60000;
  static const int HRC30_APPROVE = 50000;
}

class HyperionGasPrice {
  static const LOW_SPEED = 1 * HyperionUnitValue.G_DUST;
  static const FAST_SPEED = 1 * HyperionUnitValue.G_DUST;
  static const SUPER_FAST_SPEED = 10 * HyperionUnitValue.G_DUST;

  static GasPriceRecommend getRecommend() {
    return GasPriceRecommend.hyperionDefaultValue();
  }
}

class HyperionRpcProvider {
  static String get MAIN_API => Config.ATLAS_API;

  static String get TEST_API => Config.ATLAS_API_TEST;

  static String get rpcUrl {
    switch (HyperionConfig.chainType) {
      case HyperionChainType.mainnet:
        return MAIN_API;
      case HyperionChainType.test:
        return TEST_API;
      case HyperionChainType.local:
        return TEST_API;
    }
    return '';
  }

  /// chainId
  static int get chainId {
    switch (HyperionConfig.chainType) {
      case HyperionChainType.mainnet:
        return 1;
      case HyperionChainType.test:
        return 1;
      case HyperionChainType.local:
        break;
    }
    return 1;
  }
}

enum HyperionChainType {
  mainnet,
  test,
  local,
}

class HyperionConfig {
  static HyperionChainType chainType =
      env.buildType == BuildType.DEV ? HyperionChainType.test : HyperionChainType.mainnet;

  static String get hynRPHrc30Address {
    switch (chainType) {
      case HyperionChainType.mainnet:
        return DefaultTokenDefine.HYN_RP_HRC30.contractAddress;
      case HyperionChainType.test:
        return DefaultTokenDefine.HYN_RP_HRC30_TEST.contractAddress;
      case HyperionChainType.local:
        return DefaultTokenDefine.HYN_RP_HRC30_LOCAL.contractAddress;
    }
    return '';
  }

  /// RP量级提升
  static String get rpHoldingContractAddress {
    switch (HyperionConfig.chainType) {
      case HyperionChainType.mainnet:
        return '0xc4d64aba40481c3c012d57089828fa0bc4c63633';
      case HyperionChainType.test:
        var address = '0xc73d5d9cc5120eb588b5d517d1853a0299447a64';
        return address;
      case HyperionChainType.local:
        return "0x2190490FEcA5D47290CFA4a762b1889718913319";
    }
    return '';
  }

  /// HYN抵押传导RP
  static String get hynStakingContractAddress {
    switch (HyperionConfig.chainType) {
      case HyperionChainType.mainnet:
        return '0x6910E6F7fe7C8D5444E63F8285f5342FfC7FCA6b';
      case HyperionChainType.test:
        var address = '0x8c9b248A587619b5757A705Ac103dD5bcFA5Ab20';
        return address;
      case HyperionChainType.local:
        return "0x2190490FEcA5D47290CFA4a762b1889718913319";
    }
    return '';
  }
}
