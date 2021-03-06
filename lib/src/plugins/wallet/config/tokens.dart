import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/config/ethereum.dart';
import 'package:titan/src/plugins/wallet/config/heco.dart';
import 'package:titan/src/plugins/wallet/config/hyperion.dart';
import 'package:titan/src/plugins/wallet/token.dart';

class Tokens {
  static AssetToken getDefaultTokenByContractAddress(String contractAddress) {
    List<AssetToken> tokens = defaultTokens();
    for (var token in tokens) {
      if (token.contractAddress != null &&
          token.contractAddress.toLowerCase() == contractAddress?.toLowerCase()) {
        return token;
      }
    }
    return null;
  }

  static String getCoinIconPathBySymbol(String symbol) {
    List<AssetToken> tokens = defaultTokens();
    for (var token in tokens) {
      if (token.symbol == symbol) {
        return token.logo;
      }
    }
    return "";
  }

  static List<AssetToken> defaultContractTokensByCoinType(int coinType) {
    List<AssetToken> tokens = [];
    
    if (coinType == CoinType.HYN_ATLAS) {
      switch (HyperionConfig.chainType) {
        case HyperionChainType.mainnet:
          tokens.add(DefaultTokenDefine.HYN_RP_HRC30);
          break;
        case HyperionChainType.test:
          tokens.add(DefaultTokenDefine.HYN_RP_HRC30_TEST);
          break;
        case HyperionChainType.local:
          tokens.add(DefaultTokenDefine.HYN_RP_HRC30_LOCAL);
          break;
      }
    } else if (coinType == CoinType.ETHEREUM) {
      switch (EthereumConfig.chainType) {
        case EthereumChainType.mainnet:
          tokens.add(DefaultTokenDefine.USDT_ERC20);
          break;
        case EthereumChainType.ropsten:
          tokens.add(DefaultTokenDefine.USDT_ERC20_ROPSTEN);
          break;
        case EthereumChainType.rinkeby:
          break;
        case EthereumChainType.local:
          break;
      }
    } else if (coinType == CoinType.HB_HT) {
      switch (HecoConfig.chainType) {
        case HecoChainType.mainnet:
          //tokens.add(DefaultTokenDefine.HUSD);
          tokens.add(DefaultTokenDefine.HUSDT);
          tokens.add(DefaultTokenDefine.HYN_HECO);
          tokens.add(DefaultTokenDefine.RP_HECO);
          break;
        case HecoChainType.test:
          //tokens.add(DefaultTokenDefine.HUSD_TEST);
          tokens.add(DefaultTokenDefine.HUSDT_TEST);
          tokens.add(DefaultTokenDefine.HYN_HECO_TEST);
          tokens.add(DefaultTokenDefine.RP_HECO_TEST);

          break;
      }
    }
    return tokens;
  }

  static List<AssetToken> defaultTokens() {
    List<AssetToken> tokens = [];

    
    // hyperion
    // tokens.add(DefaultTokenDefine.HYN_Atlas);
    // tokens.addAll(defaultContractTokensByCoinType(CoinType.HYN_ATLAS));

    // ethereum
    tokens.add(DefaultTokenDefine.ETHEREUM);
    tokens.addAll(defaultContractTokensByCoinType(CoinType.ETHEREUM));

    // bitcoin
    tokens.add(DefaultTokenDefine.BTC);

    // huobi heco
    tokens.add(DefaultTokenDefine.HT);
    tokens.addAll(defaultContractTokensByCoinType(CoinType.HB_HT));

    return tokens;
  }
}

///available tokens
class DefaultTokenDefine {
  /// bitcoin
  static const BTC = const AssetToken(
    name: 'BITCOIN',
    decimals: 8,
    logo: 'res/drawable/ic_token_btc.png',
    symbol: 'BTC',
  );

  /// hyperion
  static const HYN_Atlas = const AssetToken(
    name: "Hyperion",
    decimals: 18,
    contractAddress: null,
    logo: "res/drawable/ic_token_hyn.png",
    symbol: 'HYN',
  );

  static const HYN_RP_HRC30 = const AssetToken(
    name: "Red Pocket",
    decimals: 18,
    contractAddress: '0x88880126bC73107118f18000309d10dB9f1d6a14',
    logo: "res/drawable/ic_token_rp.png",
    symbol: 'RP',
  );

  static const HYN_RP_HRC30_TEST = const AssetToken(
    name: "Red Pocket",
    decimals: 18,
    contractAddress: '0x562D6AFA2A0aD94c8B2946e23C96E27F3cD023e8',
    // old
    // contractAddress: '0x6175228cBAbFEC03B3E67953501180B35ae55494',
    logo: "res/drawable/ic_token_rp.png",
    symbol: 'RP',
  );

  static const HYN_RP_HRC30_LOCAL = const AssetToken(
    name: "Red Pocket",
    decimals: 18,
    contractAddress: '0xdB86E8bD3d8d7cE0a757DAD02Cbb6fb704383df0',
    logo: "res/drawable/ic_token_rp.png",
    symbol: 'RP',
  );

  /// ethereum
  static const ETHEREUM = const AssetToken(
    name: 'Ethereum',
    decimals: 18,
    contractAddress: null,
    logo: 'res/drawable/ic_token_eth.png',
    symbol: 'ETH',
  );

  static const HYN_ERC20 = const AssetToken(
    name: 'Hyperion',
    decimals: 18,
    contractAddress: '0xe99a894a69d7c2e3c92e61b64c505a6a57d2bc07',
    logo: "res/drawable/ic_token_hyn.png",
    symbol: 'HYN ERC20',
  );

  static const USDT_ERC20 = const AssetToken(
    name: 'Tether USD',
    decimals: 6,
    logo: 'res/drawable/ic_token_usdt.png',
    contractAddress: '0xdac17f958d2ee523a2206206994597c13d831ec7',
    symbol: 'USDT',
  );

  static const USDT_ERC20_ROPSTEN = const AssetToken(
    name: 'Tether USD',
    decimals: 6,
    logo: 'res/drawable/ic_token_usdt.png',
    contractAddress: '0xE82B8Eb1ce4684475eFc1655928dD012fb5Fa0Bb',
    symbol: 'USDT',
  );

  static const HYN_ROPSTEN = const AssetToken(
      name: 'Hyperion ROPSTEN',
      decimals: 18,
      contractAddress: '0xE2Ba724b516Bacca8646Ad72796d23Af39C610A6',
      logo: "res/drawable/ic_token_hyn.png",
      symbol: 'HYN ERC20');

  static const HYN_RINKEBY = const AssetToken(
      name: 'Hyperion RINKEBY',
      decimals: 18,
      contractAddress: '0x97B9e0EfeF243720FB024C823a39cBD73C25D601',
      logo: "res/drawable/ic_token_hyn.png",
      symbol: 'HYN ERC20');

  static final HYN_LOCAL = AssetToken(
      name: 'Hyperion LOCAL',
      decimals: 18,
      contractAddress: '0x97B9e0EfeF243720FB024C823a39cBD73C25D601',
      logo: "res/drawable/ic_token_hyn.png",
      symbol: 'HYN ERC20');

  /// huobi heco
  static const HT = const AssetToken(
    name: "Huobi HT",
    decimals: 18,
    contractAddress: null,
    logo: "res/drawable/ic_token_ht.png",
    symbol: 'HT',
  );

  static final HUSD = AssetToken(
    name: 'Huobi HUSD',
    decimals: 8,
    contractAddress: '0x0298c2b32eae4da002a15f36fdf7615bea3da047',
    logo: "res/drawable/ic_token_husd.png",
    symbol: 'HUSD',
  );

  static final HUSD_TEST = AssetToken(
    name: 'Huobi HUSD',
    decimals: 18,
    contractAddress: '0x8Dd66eefEF4B503EB556b1f50880Cc04416B916B',
    logo: "res/drawable/ic_token_husd.png",
    symbol: 'HUSD',
  );

  static final HUSDT = AssetToken(
    name: 'Heco USDT',
    decimals: 18,
    contractAddress: '0xa71edc38d189767582c38a3145b5873052c3e47a',
    logo: 'res/drawable/ic_token_usdt.png',
    symbol: 'USDT',
  );

  static final HUSDT_TEST = AssetToken(
    name: 'Heco USDT',
    decimals: 6,
    contractAddress: '0x04F535663110A392A6504839BEeD34E019FdB4E0',
    logo: 'res/drawable/ic_token_usdt.png',
    symbol: 'USDT',
  );

  static const HYN_HECO = const AssetToken(
    name: "Heco HYN",
    decimals: 18,
    contractAddress: '0x3aC19481FAce71565155F370B3E34A1178745382',
    logo: "res/drawable/ic_token_hyn.png",
    symbol: 'HYN',
  );

  static const HYN_HECO_TEST = const AssetToken(
    name: "Heco HYN",
    decimals: 18,
    contractAddress: '0x4A1E6629a1f97c0A089FAd4e80C6A0415760CF39',
    logo: "res/drawable/ic_token_hyn.png",
    symbol: 'HYN',
  );

  static const RP_HECO = const AssetToken(
    name: "Heco RP",
    decimals: 18,
    contractAddress: '0x057899Dd6FcB69b23f3b4DC6c7c2bFA4A8a0b0EE',
    logo: "res/drawable/ic_token_rp.png",
    symbol: 'RP',
  );

  static const RP_HECO_TEST = const AssetToken(
    name: "Heco RP",
    decimals: 18,
    contractAddress: '0xD949597c2829F8B4F023f7280d83210d18C46958',
    logo: "res/drawable/ic_token_rp.png",
    symbol: 'RP',
  );
}
