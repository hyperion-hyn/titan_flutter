// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keystore.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeyStore _$TrustWalletKeyStoreFromJson(Map<String, dynamic> json) {
  return KeyStore(
    fileName: json['fileName'] as String,
  )
    ..name = json['name'] as String
    ..isMnemonic = json['isMnemonic'] as bool
    ..identifier = json['identifier'] as String;
}

Map<String, dynamic> _$TrustWalletKeyStoreToJson(
        KeyStore instance) =>
    <String, dynamic>{
      'name': instance.name,
      'isMnemonic': instance.isMnemonic,
      'identifier': instance.identifier,
      'fileName': instance.fileName,
    };
