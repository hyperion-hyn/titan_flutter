// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_share_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpShareEntity _$RpShareEntityFromJson(Map<String, dynamic> json) {
  return RpShareEntity(
    (json['details'] as List)
        ?.map((e) => e == null
            ? null
            : RpShareDetailEntity.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['info'] == null
        ? null
        : RpShareInfoEntity.fromJson(json['info'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RpShareEntityToJson(RpShareEntity instance) =>
    <String, dynamic>{
      'details': instance.details,
      'info': instance.info,
    };

RpShareDetailEntity _$RpShareDetailEntityFromJson(Map<String, dynamic> json) {
  return RpShareDetailEntity(
    json['address'] as String,
    json['avatar'] as String,
    json['hynAmount'] as String,
    json['isBest'] as bool,
    json['rpAmount'] as String,
    json['username'] as String,
  );
}

Map<String, dynamic> _$RpShareDetailEntityToJson(
        RpShareDetailEntity instance) =>
    <String, dynamic>{
      'address': instance.address,
      'avatar': instance.avatar,
      'hynAmount': instance.hynAmount,
      'isBest': instance.isBest,
      'rpAmount': instance.rpAmount,
      'username': instance.username,
    };

RpShareInfoEntity _$RpShareInfoEntityFromJson(Map<String, dynamic> json) {
  return RpShareInfoEntity(
    json['address'] as String,
    json['alreadyGot'] as bool,
    json['avatar'] as String,
    (json['coordinates'] as List)?.map((e) => (e as num)?.toDouble())?.toList(),
    json['createdAt'] as int,
    json['greeting'] as String,
    json['hasPWD'] as bool,
    json['id'] as String,
    json['isNewBee'] as bool,
    json['owner'] as String,
    json['range'] as int,
    json['rpType'] as String,
    json['state'] as String,
    json['userIsNewBee'] as bool,
  );
}

Map<String, dynamic> _$RpShareInfoEntityToJson(RpShareInfoEntity instance) =>
    <String, dynamic>{
      'address': instance.address,
      'alreadyGot': instance.alreadyGot,
      'avatar': instance.avatar,
      'coordinates': instance.coordinates,
      'createdAt': instance.createdAt,
      'greeting': instance.greeting,
      'hasPWD': instance.hasPWD,
      'id': instance.id,
      'isNewBee': instance.isNewBee,
      'owner': instance.owner,
      'range': instance.range,
      'rpType': instance.rpType,
      'state': instance.state,
      'userIsNewBee': instance.userIsNewBee,
    };
