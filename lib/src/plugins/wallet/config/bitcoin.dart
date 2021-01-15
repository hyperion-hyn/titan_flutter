import 'package:titan/env.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';

class BitcoinGasPrice {
  static const BTC_LOW_SPEED = 15; // sat/b
  static const BTC_FAST_SPEED = 30; // sat/b
  static const BTC_SUPER_FAST_SPEED = 60; // sat/b
  static const BTC_RAWTX_SIZE = 225; // sat/b

  static GasPriceRecommend getRecommend() {
    return WalletInheritedModel.of(Keys.rootKey.currentContext).btcGasPriceRecommend;
  }
}

class BitcoinRpcProvider {
  static String get MAIN_API => 'https://api.wallet.hyn.space/wallet/btc/';

  static String get LOCAL_API => 'https://api.wallet.hyn.space/wallet/btc/';

  static String get rpcUrl {
    switch (BitcoinConfig.chainType) {
      case BitcoinChainType.main:
        return MAIN_API;
      case BitcoinChainType.local:
        return LOCAL_API;
    }
    return '';
  }
}

class BitcoinExplore {
  static String get BITCOIN_TRANSATION_DETAIL => 'https://blockchair.com/bitcoin/transaction/';
}

enum BitcoinChainType {
  main,
  local,
}

class BitcoinConfig {
  static BitcoinChainType chainType = env.buildType == BuildType.DEV ? BitcoinChainType.local : BitcoinChainType.main;
}
