// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_share_req_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpShareReqEntity _$RpShareReqEntityFromJson(Map<String, dynamic> json) {
  return RpShareReqEntity(
    json['id'] as String,
    json['address'] as String,
    (json['lat'] as num)?.toDouble(),
    (json['lng'] as num)?.toDouble(),
    json['count'] as int,
    json['greeting'] as String,
    json['hynamount'] as String,
    json['hynsignedTX'] as String,
    json['isNewBee'] as bool,
    json['password'] as String,
    (json['range'] as num)?.toDouble(),
    json['rpamount'] as String,
    json['rpsignedTX'] as String,
    json['rptype'] as String,
  );
}

Map<String, dynamic> _$RpShareReqEntityToJson(RpShareReqEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'address': instance.address,
      'lat': instance.lat,
      'lng': instance.lng,
      'count': instance.count,
      'greeting': instance.greeting,
      'hynamount': instance.hynAmount,
      'hynsignedTX': instance.hynSignedTX,
      'isNewBee': instance.isNewBee,
      'password': instance.password,
      'range': instance.range,
      'rpamount': instance.rpAmount,
      'rpsignedTX': instance.rpSignedTX,
      'rptype': instance.rpType,
    };
