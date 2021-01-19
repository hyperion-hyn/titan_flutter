// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_share_config_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpShareConfigEntity _$RpShareConfigEntityFromJson(Map<String, dynamic> json) {
  return RpShareConfigEntity(
    json['hynMin'] as String,
    json['receiveAddr'] as String,
    json['rpMin'] as String,
  );
}

Map<String, dynamic> _$RpShareConfigEntityToJson(
        RpShareConfigEntity instance) =>
    <String, dynamic>{
      'hynMin': instance.hynMin,
      'receiveAddr': instance.receiveAddr,
      'rpMin': instance.rpMin,
    };
