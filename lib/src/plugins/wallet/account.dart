import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/token.dart';

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

  factory Account.fromJson(Map<dynamic, dynamic> json,
      [bool isMainNet = true]) {
    AssetToken token;
    var erc20Tokens = <AssetToken>[];
    if (json['coinType'] == CoinType.ETHEREUM) {
      token = Tokens.ETHEREUM;
      //支持的ERC20代币
      if (isMainNet) {
        erc20Tokens.add(Tokens.HYN);
      } else {
        erc20Tokens.add(Tokens.HYN_ROPSTEN);
      }
    } else {
      //Maybe support later
    }
    return Account(
      address: json['address'],
      derivationPath: json['derivationPath'],
      coinType: json['coinType'],
      token: token,
      erc20AssetTokens: erc20Tokens,
    );
  }

  @override
  String toString() {
    return 'Account{address: $address, derivationPath: $derivationPath, coinType: $coinType, token: $token, erc20AssetTokens: $erc20AssetTokens}';
  }
}
