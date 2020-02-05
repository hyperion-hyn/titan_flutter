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
  final List<AssetToken> contractAssetTokens;

  Account({
    this.address,
    this.derivationPath,
    this.coinType,
    this.token,
    this.contractAssetTokens,
  });

  factory Account.fromJsonWithNet(Map<dynamic, dynamic> json, [bool isMainNet = true]) {
    AssetToken token;
    var erc20Tokens = <AssetToken>[];
    if (json['coinType'] == CoinType.ETHEREUM) {
      token = SupportedTokens.ETHEREUM;
      //active contract tokens
      if (isMainNet) {
        erc20Tokens.add(SupportedTokens.HYN);
        erc20Tokens.add(SupportedTokens.USDT_ERC20);
      } else {
        erc20Tokens.add(SupportedTokens.HYN_ROPSTEN);
        erc20Tokens.add(SupportedTokens.USDT_ERC20_ROPSTEN);
      }
    } else if (json['coinType'] == CoinType.BITCOIN) {
      token = SupportedTokens.BTC;
    } else {
      //TODO more coin support
    }
    return Account(
      address: json['address'],
      derivationPath: json['derivationPath'],
      coinType: json['coinType'],
      token: token,
      contractAssetTokens: erc20Tokens,
    );
  }

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);

  @override
  String toString() {
    return 'Account{address: $address, derivationPath: $derivationPath, coinType: $coinType, token: $token, contractAssetTokens: $contractAssetTokens}';
  }
}
