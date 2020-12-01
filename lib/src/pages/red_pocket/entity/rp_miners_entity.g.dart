// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_miners_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpMinersEntity _$RpMinersEntityFromJson(Map<String, dynamic> json) {
  return RpMinersEntity(
    json['inviter'] == null
        ? null
        : RpMinerInfo.fromJson(json['inviter'] as Map<String, dynamic>),
    (json['miners'] as List)
        ?.map((e) =>
            e == null ? null : RpMinerInfo.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$RpMinersEntityToJson(RpMinersEntity instance) =>
    <String, dynamic>{
      'inviter': instance.inviter,
      'miners': instance.miners,
    };

RpMinerInfo _$RpMinerInfoFromJson(Map<String, dynamic> json) {
  return RpMinerInfo(
    json['address'] as String,
    json['avatar'] as String,
    json['inviteTime'] as int,
    json['level'] as int,
    json['name'] as String,
  );
}

Map<String, dynamic> _$RpMinerInfoToJson(RpMinerInfo instance) =>
    <String, dynamic>{
      'address': instance.address,
      'avatar': instance.avatar,
      'inviteTime': instance.inviteTime,
      'level': instance.level,
      'name': instance.name,
    };
