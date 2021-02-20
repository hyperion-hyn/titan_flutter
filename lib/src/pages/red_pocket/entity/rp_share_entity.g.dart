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
            : RpShareOpenEntity.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['info'] == null
        ? null
        : RpShareSendEntity.fromJson(json['info'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RpShareEntityToJson(RpShareEntity instance) =>
    <String, dynamic>{
      'details': instance.details?.map((e) => e?.toJson())?.toList(),
      'info': instance.info?.toJson(),
    };

RpShareOpenEntity _$RpShareOpenEntityFromJson(Map<String, dynamic> json) {
  return RpShareOpenEntity(
    json['id'] as String,
    json['address'] as String,
    json['avatar'] as String,
    json['hynAmount'] as String,
    json['isBest'] as bool,
    json['rpAmount'] as String,
    json['username'] as String,
    json['createdAt'] as int,
    json['location'] as String,
    json['getHYNAmount'] as String,
    json['getRPAmount'] as String,
    (json['range'] as num)?.toDouble(),
    json['rpType'] as String,
    json['greeting'] as String,
    json['rpHash'] as String,
    json['hynHash'] as String,
  );
}

Map<String, dynamic> _$RpShareOpenEntityToJson(RpShareOpenEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'address': instance.address,
      'avatar': instance.avatar,
      'hynAmount': instance.hynAmount,
      'isBest': instance.isBest,
      'rpAmount': instance.rpAmount,
      'username': instance.username,
      'createdAt': instance.createdAt,
      'location': instance.location,
      'getHYNAmount': instance.getHYNAmount,
      'getRPAmount': instance.getRPAmount,
      'range': instance.range,
      'rpType': instance.rpType,
      'greeting': instance.greeting,
      'rpHash': instance.rpHash,
      'hynHash': instance.hynHash,
    };

RpShareSendEntity _$RpShareSendEntityFromJson(Map<String, dynamic> json) {
  return RpShareSendEntity(
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
    (json['range'] as num)?.toDouble(),
    json['rpType'] as String,
    json['state'] as String,
    json['userIsNewBee'] as bool,
    json['location'] as String,
    json['total'] as int,
    json['gotCount'] as int,
    json['hynAmount'] as String,
    json['rpAmount'] as String,
    json['rpHash'] as String,
    json['hynHash'] as String,
    (json['lat'] as num)?.toDouble(),
    (json['lng'] as num)?.toDouble(),
    json['HYNRefundHash'] as String,
    json['RPRefundHash'] as String,
  );
}

Map<String, dynamic> _$RpShareSendEntityToJson(RpShareSendEntity instance) =>
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
      'location': instance.location,
      'total': instance.total,
      'gotCount': instance.gotCount,
      'hynAmount': instance.hynAmount,
      'rpAmount': instance.rpAmount,
      'rpHash': instance.rpHash,
      'hynHash': instance.hynHash,
      'lat': instance.lat,
      'lng': instance.lng,
      'HYNRefundHash': instance.hynRefundHash,
      'RPRefundHash': instance.rpRefundHash,
    };
