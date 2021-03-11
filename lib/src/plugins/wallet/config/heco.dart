import 'package:titan/config.dart';
import 'package:titan/env.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/plugins/wallet/config/ethereum.dart';
import 'package:titan/src/plugins/wallet/config/tokens.dart';

class HecoGasLimit {
  static const int TRANSFER = 21000;
  static const int HRC20_TRANSFER = 60000;
  static const int HRC20_APPROVE = 50000;

  static const int BRIDGE_CONTRACT_BURN_TOKEN_CALL = 100000;
}

class HecoGasPrice {
  static const LOW_SPEED = 1 * EthereumUnitValue.G_WEI;
  static const FAST_SPEED = 1 * EthereumUnitValue.G_WEI;
  static const SUPER_FAST_SPEED = 10 * EthereumUnitValue.G_WEI;

  static GasPriceRecommend getRecommend() {
    return GasPriceRecommend.hecoDefaultValue();
  }
}

enum HecoChainType { mainnet, test }

class HecoConfig {
  static HecoChainType chainType =
      env.buildType == BuildType.DEV ? HecoChainType.test : HecoChainType.mainnet;

  static String getUsdtErc20Address() {
    switch (HecoConfig.chainType) {
      case HecoChainType.mainnet:
        return DefaultTokenDefine.HUSDT.contractAddress;
      case HecoChainType.test:
        return DefaultTokenDefine.HUSDT_TEST.contractAddress;
    }
    return '';
  }

  static String get hynContractAddress {
    switch (chainType) {
      case HecoChainType.mainnet:
        return DefaultTokenDefine.HYN_HECO.contractAddress;
      case HecoChainType.test:
        return DefaultTokenDefine.HYN_HECO_TEST.contractAddress;
    }
    return '';
  }

  static String get burnTokenContractAddress {
    switch (chainType) {
      case HecoChainType.mainnet:
        return '';
      case HecoChainType.test:
        return '0xA99Dd6fb2E6D97e3A2AFCb5ac1699693e4B2E6A6';
    }
    return '';
  }
}

class HecoRpcProvider {
  static String MAIN_API = Config.HECO_RPC_API;

  static String TEST_API = 'https://http-testnet.hecochain.com';

  static String get rpcUrl {
    switch (HecoConfig.chainType) {
      case HecoChainType.mainnet:
        return MAIN_API;
      case HecoChainType.test:
        return TEST_API;
    }
    return MAIN_API;
  }

  /// chainId
  static int get chainId {
    switch (HecoConfig.chainType) {
      case HecoChainType.mainnet:
        return 128;
      case HecoChainType.test:
        return 256;
    }
    return 128;
  }
}

class HecoExplore {
  static String MAIN_SCAN_API = 'https://heco-api.hyn.space';
  static String TEST_SCAN_API = 'http://heco-api.test.hyn.space';
  static String MAIN_SCAN_WEB = 'https://scan.hecochain.com';
  static String TEST_SCAN_WEB = 'https://scan-testnet.hecochain.com';

  static String get hecoScanApi {
    switch (HecoConfig.chainType) {
      case HecoChainType.mainnet:
        return MAIN_SCAN_API;
      case HecoChainType.test:
        return TEST_SCAN_API;
      default:
        return MAIN_SCAN_API;
    }
  }

  static String get hecoScanWeb {
    if (HecoConfig.chainType == HecoChainType.mainnet) {
      return MAIN_SCAN_WEB;
    } else if (HecoConfig.chainType == HecoChainType.test) {
      return TEST_SCAN_WEB;
    }
    return MAIN_SCAN_WEB;
  }
}
