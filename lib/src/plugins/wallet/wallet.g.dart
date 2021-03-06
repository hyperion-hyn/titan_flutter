// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Wallet _$WalletFromJson(Map<String, dynamic> json) {
  return Wallet(
    keystore: json['keystore'] == null
        ? null
        : KeyStore.fromJson(json['keystore'] as Map<String, dynamic>),
    accounts: (json['accounts'] as List)
        ?.map((e) =>
            e == null ? null : Account.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    walletExpandInfoEntity:
        Wallet.expandInfoFromJson(json['walletExpandInfoEntity']),
  );
}

Map<String, dynamic> _$WalletToJson(Wallet instance) => <String, dynamic>{
      'accounts': instance.accounts?.map((e) => e?.toJson())?.toList(),
      'keystore': instance.keystore?.toJson(),
      'walletExpandInfoEntity':
          Wallet.expandInfoToJson(instance.walletExpandInfoEntity),
    };
