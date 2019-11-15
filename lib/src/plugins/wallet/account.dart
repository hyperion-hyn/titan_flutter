import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/token.dart';

part 'account.g.dart';

@JsonSerializable()
class Account {
  final String address;
  final String derivationPath;
  final int coinType;

  final AssetToken token;
  final List<AssetToken> erc20AssetTokens;

  Account({
    this.address,
    this.derivationPath,
    this.coinType,
    this.token,
    this.erc20AssetTokens,
  });

  factory Account.fromJsonWithNet(Map<dynamic, dynamic> json, [bool isMainNet = true]) {
    AssetToken token;
    var erc20Tokens = <AssetToken>[];
    if (json['coinType'] == CoinType.ETHEREUM) {
      token = SupportedTokens.ETHEREUM;
      //active erc20 tokens
      if (isMainNet) {
        erc20Tokens.add(SupportedTokens.HYN);
//        erc20Tokens.add(SupportedTokens.USDT_ERC20);
      } else {
        erc20Tokens.add(SupportedTokens.HYN_ROPSTEN);
      }
    } else {
      //TODO
      //Maybe support more later
    }
    return Account(
      address: json['address'],
      derivationPath: json['derivationPath'],
      coinType: json['coinType'],
      token: token,
      erc20AssetTokens: erc20Tokens,
    );
  }

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);

  @override
  String toString() {
    return 'Account{address: $address, derivationPath: $derivationPath, coinType: $coinType, token: $token, erc20AssetTokens: $erc20AssetTokens}';
  }
}
