// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) {
  return Account(
    address: json['address'] as String,
    derivationPath: json['derivationPath'] as String,
    coinType: json['coinType'] as int,
    token: json['token'] == null
        ? null
        : AssetToken.fromJson(json['token'] as Map<String, dynamic>),
    contractAssetTokens: (json['contractAssetTokens'] as List)
        ?.map((e) =>
            e == null ? null : AssetToken.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    extendedPublicKey: json['extendedPublicKey'] as String,
  );
}

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'address': instance.address,
      'derivationPath': instance.derivationPath,
      'coinType': instance.coinType,
      'extendedPublicKey': instance.extendedPublicKey,
      'token': instance.token?.toJson(),
      'contractAssetTokens':
          instance.contractAssetTokens?.map((e) => e?.toJson())?.toList(),
    };
