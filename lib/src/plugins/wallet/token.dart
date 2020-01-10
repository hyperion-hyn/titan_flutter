//数字资产

import 'package:json_annotation/json_annotation.dart';

part 'token.g.dart';

@JsonSerializable()
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
    logo: 'https://tether.to/wp-content/uploads/2015/02/Tether_logo_dm-e1537976324456.png',
    contractAddress: '0xdac17f958d2ee523a2206206994597c13d831ec7',
    symbol: 'USDT',
  );

  static const HYN_ROPSTEN = const AssetToken(
      name: 'Hyperion ROPSTEN',
      decimals: 18,
      contractAddress: '0xaebbada2bece10c84cbeac637c438cb63e1446c9',
      logo: 'res/drawable/hyn_logo.png',
      symbol: 'HYN');

  static List<AssetToken> allContractTokens(bool isMainNet) {
    if (isMainNet) {
      return [HYN, USDT_ERC20];
    } else {
      return [HYN_ROPSTEN];
    }
  }
}
