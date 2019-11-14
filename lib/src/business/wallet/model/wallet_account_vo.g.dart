// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_account_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletAccountVo _$WalletAccountVoFromJson(Map<String, dynamic> json) {
  return WalletAccountVo(
    wallet: json['wallet'] == null
        ? null
        : Wallet.fromJson(json['wallet'] as Map<String, dynamic>),
    account: json['account'] == null
        ? null
        : Account.fromJson(json['account'] as Map<String, dynamic>),
    assetToken: json['assetToken'] == null
        ? null
        : AssetToken.fromJson(json['assetToken'] as Map<String, dynamic>),
    name: json['name'] as String,
    balance: (json['count'] as num)?.toDouble(),
    currencyRate: (json['currencyRate'] as num)?.toDouble(),
    currencyUnit: json['currencyUnit'] as String,
    ethCurrencyRate: (json['ethCurrencyRate'] as num)?.toDouble(),
    symbol: json['symbol'] as String,
    amount: (json['amount'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$WalletAccountVoToJson(WalletAccountVo instance) =>
    <String, dynamic>{
      'wallet': instance.wallet,
      'account': instance.account,
      'assetToken': instance.assetToken,
      'name': instance.name,
      'count': instance.balance,
      'currencyRate': instance.currencyRate,
      'ethCurrencyRate': instance.ethCurrencyRate,
      'currencyUnit': instance.currencyUnit,
      'symbol': instance.symbol,
      'amount': instance.amount,
    };
