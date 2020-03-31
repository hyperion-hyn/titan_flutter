import 'package:titan/src/plugins/wallet/wallet.dart';

part 'token.g.dart';

class AssetToken {
  final int decimals;
  final String name;
  final String symbol;
  final String logo;
  final String contractAddress;

  const AssetToken({this.name, this.decimals, this.contractAddress, this.symbol, this.logo});

  @override
  String toString() {
    return 'AssetToken{decimals: $decimals, name: $name, symbol: $symbol, logo: $logo, contractAddress: $contractAddress}';
  }

  factory AssetToken.fromJson(Map<String, dynamic> json) => _$AssetTokenFromJson(json);

  Map<String, dynamic> toJson() => _$AssetTokenToJson(this);
}

///available tokens
class SupportedTokens {
  static const BTC = const AssetToken(
    name: 'BITCOIN',
    decimals: 8,
    logo: 'https://www.altilly.com/assets/img/BTC_large.png',
    symbol: 'BTC',
  );

  static const ETHEREUM = const AssetToken(
    name: 'Ethereum',
    decimals: 18,
    contractAddress: null,
    logo: 'res/drawable/eth_logo.png',
    symbol: 'ETH',
  );

  static const HYN = const AssetToken(
      name: 'Hyperion',
      decimals: 18,
      contractAddress: '0xe99a894a69d7c2e3c92e61b64c505a6a57d2bc07',
      logo: 'res/drawable/hyn_logo.png',
      symbol: 'HYN');

  static const USDT_ERC20 = const AssetToken(
    name: 'Tether USD',
    decimals: 6,
//    logo: 'https://tether.to/wp-content/uploads/2015/02/Tether_logo_dm-e1537976324456.png',
    logo: 'res/drawable/usdt_logo.png',
    contractAddress: '0xdac17f958d2ee523a2206206994597c13d831ec7',
    symbol: 'USDT',
  );

  static const USDT_ERC20_ROPSTEN = const AssetToken(
    name: 'Tether USD',
    decimals: 6,
    logo: 'res/drawable/usdt_logo.png',
    contractAddress: '0xE82B8Eb1ce4684475eFc1655928dD012fb5Fa0Bb',
    symbol: 'USDT',
  );

  static const HYN_ROPSTEN = const AssetToken(
      name: 'Hyperion ROPSTEN',
      decimals: 18,
      contractAddress: '0xaebbada2bece10c84cbeac637c438cb63e1446c9',
      logo: 'res/drawable/hyn_logo.png',
      symbol: 'HYN');

  static const HYN_LOCAL = const AssetToken(
      name: 'Hyperion ROPSTEN',
      decimals: 18,
      contractAddress: '0x05D9c03Fd700B0fc3bD10ef4Ac66d343ff9E69D7',
      logo: 'res/drawable/hyn_logo.png',
      symbol: 'HYN');

  static List<AssetToken> allContractTokens(EthereumNetType netType) {
    if (netType == EthereumNetType.main) {
      return [HYN, USDT_ERC20];
    } else if (netType == EthereumNetType.repsten) {
      return [HYN_ROPSTEN, USDT_ERC20_ROPSTEN];
    } else {
      return [HYN_LOCAL];
    }
  }
}
