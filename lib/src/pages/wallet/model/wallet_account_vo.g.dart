// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_account_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletAccountVo _$WalletAccountVoFromJson(Map<String, dynamic> json) {
  return WalletAccountVo(
    account: json['account'] == null
        ? null
        : Account.fromJson(json['account'] as Map<String, dynamic>),
    assetToken: json['assetToken'] == null
        ? null
        : AssetToken.fromJson(json['assetToken'] as Map<String, dynamic>),
    balance: (json['balance'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$WalletAccountVoToJson(WalletAccountVo instance) =>
    <String, dynamic>{
      'account': instance.account,
      'assetToken': instance.assetToken,
      'balance': instance.balance,
    };
