// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckInModel _$CheckInModelFromJson(Map<String, dynamic> json) {
  return CheckInModel(
    json['day'] as String,
    json['total'] as int,
    (json['detail'] as List)
        ?.map((e) => e == null ? null : CheckInModelDetail.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['completed'] as bool,
  );
}

Map<String, dynamic> _$CheckInModelToJson(CheckInModel instance) => <String, dynamic>{
      'day': instance.day,
      'total': instance.total,
      'detail': instance.detail,
      'completed': instance.completed,
    };

CheckInModelDetail _$CheckInModelDetailFromJson(Map<String, dynamic> json) {
  return CheckInModelDetail(
    json['action'] as String,
    json['state'] == null ? null : CheckInModelState.fromJson(json['state'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CheckInModelDetailToJson(CheckInModelDetail instance) => <String, dynamic>{
      'action': instance.action,
      'state': instance.state,
    };

CheckInModelState _$CheckInModelStateFromJson(Map<String, dynamic> json) {
  return CheckInModelState(
    json['total'] as int,
    json['real'] as int,
    (json['pois'] as List)
        ?.map((e) => e == null ? null : CheckInModelPoi.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$CheckInModelStateToJson(CheckInModelState instance) => <String, dynamic>{
      'total': instance.total,
      'real': instance.real,
      'pois': instance.pois,
    };

CheckInModelPoi _$CheckInModelPoiFromJson(Map<String, dynamic> json) {
  return CheckInModelPoi(
    json['poi_id'] as String,
    (json['coordinates'] as List)?.map((e) => (e as num)?.toDouble())?.toList(),
    json['name'] as String,
    json['address'] as String,
    json['category'] as String,
    json['phone'] as String,
    json['status'] as int,
    json['ext'] as String,
    json['workTime'] as String,
    json['image'] as String,
    json['isReal'] as bool,
    json['answer'] as bool,
    json['created_at'] as int,
    (json['originalImgs'] as List)?.map((e) => (e as String)?.toString())?.toList(),
    json['poiCreatedAt'] as int,
    (json['detail'] as List)?.map((e) => e == null ? null : CheckInModelPoi.fromJson(e as Map<String, dynamic>))?.toList(),
  );
}

Map<String, dynamic> _$CheckInModelPoiToJson(CheckInModelPoi instance) => <String, dynamic>{
      'poi_id': instance.poiId,
      'coordinates': instance.coordinates,
      'name': instance.name,
      'address': instance.address,
      'category': instance.category,
      'phone': instance.phone,
      'status': instance.status,
      'ext': instance.ext,
      'workTime': instance.workTime,
      'image': instance.image,
      'isReal': instance.isReal,
      'answer': instance.answer,
      'createdAt': instance.createdAt,
      'originalImgs': instance.originalImgs,
      'poiCreatedAt': instance.poiCreatedAt,
      'detail': instance.detail,
    };
