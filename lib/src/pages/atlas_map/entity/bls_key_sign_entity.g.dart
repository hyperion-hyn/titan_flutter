// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bls_key_sign_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlsKeySignEntity _$BlsKeySignEntityFromJson(Map<String, dynamic> json) {
  return BlsKeySignEntity(
    json['bls_key'] as String,
    json['bls_sign'] as String,
  );
}

Map<String, dynamic> _$BlsKeySignEntityToJson(BlsKeySignEntity instance) =>
    <String, dynamic>{
      'bls_key': instance.blsKey,
      'bls_sign': instance.blsSign,
    };
