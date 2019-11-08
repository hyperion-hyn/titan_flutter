//数字资产

import 'package:json_annotation/json_annotation.dart';

part 'token.g.dart';

@JsonSerializable()
class AssetToken {
  final int decimals;
  final String id;
  final String name;
  final String symbol;
  final String logo;
  final String erc20ContractAddress;

  const AssetToken({this.id, this.name, this.decimals, this.erc20ContractAddress, this.symbol, this.logo});

  @override
  String toString() {
    return 'AssetToken{decimals: $decimals, id: $id, name: $name, symbol: $symbol, logo: $logo, erc20ContractAddress: $erc20ContractAddress}';
  }

  factory AssetToken.fromJson(Map<String, dynamic> json) => _$AssetTokenFromJson(json);

  Map<String, dynamic> toJson() => _$AssetTokenToJson(this);
}

///可用的数字资产
class SupportedTokens {
  static const ETHEREUM = const AssetToken(
      name: 'Ethereum',
      id: 'ethereum',
      decimals: 18,
      erc20ContractAddress: null,
      logo: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/info/logo.png',
      symbol: 'ETH');

  static const HYN = const AssetToken(
      name: 'Hyperion',
      id: 'hyperion',
      decimals: 18,
      erc20ContractAddress: '0xe99a894a69d7c2e3c92e61b64c505a6a57d2bc07',
      logo:
          'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xe99a894a69d7c2e3c92e61b64c505a6a57d2bc07/logo.png',
      symbol: 'HYN');

  static const HYN_ROPSTEN = const AssetToken(
      name: 'Hyperion ROPSTEN',
      id: 'hyperion',
      decimals: 18,
      erc20ContractAddress: '0xaebbada2bece10c84cbeac637c438cb63e1446c9',
      logo:
          'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xe99a894a69d7c2e3c92e61b64c505a6a57d2bc07/logo.png',
      symbol: 'HYN');
}
