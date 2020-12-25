// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_bind_info_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountBindInfoEntity _$AccountBindInfoEntityFromJson(
    Map<String, dynamic> json) {
  return AccountBindInfoEntity(
    json['applyCount'] as int,
    json['isMaster'] as bool,
    json['isSub'] as bool,
    json['master'] as String,
    json['request'] == null
        ? null
        : Request.fromJson(json['request'] as Map<String, dynamic>),
    json['sub'] as String,
    (json['subRelationships'] as List)
        ?.map((e) => e == null
            ? null
            : SubRelationships.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$AccountBindInfoEntityToJson(
        AccountBindInfoEntity instance) =>
    <String, dynamic>{
      'applyCount': instance.applyCount,
      'isMaster': instance.isMaster,
      'isSub': instance.isSub,
      'master': instance.master,
      'request': instance.request,
      'sub': instance.sub,
      'subRelationships': instance.subRelationships,
    };

Request _$RequestFromJson(Map<String, dynamic> json) {
  return Request(
    json['id'] as int,
    json['userID'] as int,
    json['email'] as String,
    json['state'] as int,
    json['requestTime'] as int,
  );
}

Map<String, dynamic> _$RequestToJson(Request instance) => <String, dynamic>{
      'id': instance.id,
      'userID': instance.userID,
      'email': instance.email,
      'state': instance.state,
      'requestTime': instance.requestTime,
    };

SubRelationships _$SubRelationshipsFromJson(Map<String, dynamic> json) {
  return SubRelationships(
    json['userID'] as int,
    json['email'] as String,
    json['bindTime'] as int,
  );
}

Map<String, dynamic> _$SubRelationshipsToJson(SubRelationships instance) =>
    <String, dynamic>{
      'userID': instance.userID,
      'email': instance.email,
      'bindTime': instance.bindTime,
    };
