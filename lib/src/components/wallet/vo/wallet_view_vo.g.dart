// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_view_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletViewVo _$WalletViewVoFromJson(Map<String, dynamic> json) {
  return WalletViewVo(
    wallet: json['wallet'] == null
        ? null
        : Wallet.fromJson(json['wallet'] as Map<String, dynamic>),
    coins: (json['coins'] as List)
        ?.map((e) =>
            e == null ? null : CoinViewVo.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    balance: (json['balance'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$WalletViewVoToJson(WalletViewVo instance) =>
    <String, dynamic>{
      'wallet': instance.wallet?.toJson(),
      'coins': instance.coins?.map((e) => e?.toJson())?.toList(),
      'balance': instance.balance,
    };
