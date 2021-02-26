import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/components/wallet/vo/coin_view_vo.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

part 'wallet_view_vo.g.dart';

@JsonSerializable()
class WalletViewVo {
  Wallet wallet;

  ///eth, hyn etc..  account list
  List<CoinViewVo> coins;

  double balance;

  WalletViewVo({this.wallet, this.coins, this.balance});

  factory WalletViewVo.fromJson(Map<String, dynamic> json) => _$WalletViewVoFromJson(json);

  Map<String, dynamic> toJson() => _$WalletViewVoToJson(this);

  WalletViewVo copyWith([WalletViewVo target]) {
    return WalletViewVo(
        balance: target?.balance ?? this.balance,
        coins: target?.coins ?? this.coins,
        wallet: target?.wallet ?? this.wallet);
  }

  List<CoinViewVo> tokensByCoinType(int coinType) {
    List<CoinViewVo> result = List();
    coins.forEach((token) {
      if (token.coinType == coinType) {
        result.add(token);
      }
    });
    return result;
  }
}
