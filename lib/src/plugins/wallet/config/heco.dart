import 'package:titan/env.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/plugins/wallet/config/ethereum.dart';

class HecoGasLimit {
  static const int TRANSFER = 21000;
  static const int HRC20_TRANSFER = 60000;
  static const int HRC20_APPROVE = 50000;
}

class HecoGasPrice {
  static const LOW_SPEED = 1 * EthereumUnitValue.G_WEI;
  static const FAST_SPEED = 5 * EthereumUnitValue.G_WEI;
  static const SUPER_FAST_SPEED = 10 * EthereumUnitValue.G_WEI;

  static GasPriceRecommend getRecommend() {
    return GasPriceRecommend.hecoDefaultValue();
  }
}

enum HecoChainType { mainnet, test }

class HecoConfig {
  static HecoChainType chainType = env.buildType == BuildType.DEV ? HecoChainType.test : HecoChainType.mainnet;
}

class HecoRpcProvider {
  static String MAIN_API = 'https://http-mainnet.hecochain.com';

  static String TEST_API = 'https://http-testnet.hecochain.com';

  static String get rpcUrl {
    switch (HecoConfig.chainType) {
      case HecoChainType.mainnet:
        return MAIN_API;
      case HecoChainType.test:
        return TEST_API;
    }
    return '';
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
