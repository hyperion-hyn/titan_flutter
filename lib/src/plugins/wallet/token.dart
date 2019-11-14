//数字资产

import 'package:json_annotation/json_annotation.dart';

part 'token.g.dart';

@JsonSerializable()
class AssetToken {
  final int decimals;
  final String name;
  final String symbol;
  final String logo;
  final String erc20ContractAddress;

  const AssetToken({this.name, this.decimals, this.erc20ContractAddress, this.symbol, this.logo});

  @override
  String toString() {
    return 'AssetToken{decimals: $decimals, name: $name, symbol: $symbol, logo: $logo, erc20ContractAddress: $erc20ContractAddress}';
  }

  factory AssetToken.fromJson(Map<String, dynamic> json) => _$AssetTokenFromJson(json);

  Map<String, dynamic> toJson() => _$AssetTokenToJson(this);
}

///available tokens
class SupportedTokens {
  static const ETHEREUM = const AssetToken(
    name: 'Ethereum',
    decimals: 18,
    erc20ContractAddress: null,
    symbol: 'ETH',
  );

  static const HYN = const AssetToken(
      name: 'Hyperion',
      decimals: 18,
      erc20ContractAddress: '0xe99a894a69d7c2e3c92e61b64c505a6a57d2bc07',
      symbol: 'HYN');

  static const USDT_ERC20 = const AssetToken(
    name: 'Tether USD',
    decimals: 6,
    erc20ContractAddress: '0xdac17f958d2ee523a2206206994597c13d831ec7',
    symbol: 'USDT',
  );

  static const HYN_ROPSTEN = const AssetToken(
      name: 'Hyperion ROPSTEN',
      decimals: 18,
      erc20ContractAddress: '0xaebbada2bece10c84cbeac637c438cb63e1446c9',
      symbol: 'HYN');
}
