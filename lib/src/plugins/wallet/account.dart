import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/config/tokens.dart';
import 'package:titan/src/plugins/wallet/token.dart';

part 'account.g.dart';

/// 主链账户
@JsonSerializable()
class Account {
  final String address;
  final String derivationPath;
  final int coinType;
  final String extendedPublicKey;

  final AssetToken token; //主链资产
  final List<AssetToken> contractAssetTokens; //合约资产

  Account({
    this.address,
    this.derivationPath,
    this.coinType,
    this.token,
    this.contractAssetTokens,
    this.extendedPublicKey,
  });

  factory Account.mainAccountFromJson(Map<dynamic, dynamic> json) {
    AssetToken token;
    // var erc20Tokens = <AssetToken>[];
    int coinType = json['coinType'];
    if (coinType == CoinType.ETHEREUM) {
      token = DefaultTokenDefine.ETHEREUM;
    } else if (coinType == CoinType.BITCOIN) {
      token = DefaultTokenDefine.BTC;
    } else if (coinType == CoinType.HYN_ATLAS) {
      token = DefaultTokenDefine.HYN_Atlas;
    } else if (coinType == CoinType.HB_HT) {
      token = DefaultTokenDefine.HT;
    }

    // erc20Tokens.addAll(Tokens.contractTokensByCoinType(coinType));

    return Account(
      address: json['address'],
      derivationPath: json['derivationPath'],
      coinType: coinType,
      extendedPublicKey: json['extendedPublicKey'],
      token: token,
      // contractAssetTokens: erc20Tokens,
    );
  }

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);

  @override
  String toString() {
    return 'Account{address: $address, derivationPath: $derivationPath, coinType: $coinType, token: $token, contractAssetTokens: $contractAssetTokens}';
  }
}
