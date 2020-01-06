// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletVo _$WalletVoFromJson(Map<String, dynamic> json) {
  return WalletVo(
    wallet: json['wallet'] == null
        ? null
        : Wallet.fromJson(json['wallet'] as Map<String, dynamic>),
    coins: (json['coins'] as List)
        ?.map((e) =>
            e == null ? null : CoinVo.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$WalletVoToJson(WalletVo instance) => <String, dynamic>{
      'wallet': instance.wallet,
      'coins': instance.coins,
    };
