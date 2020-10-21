// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map3_introduce_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map3IntroduceEntity _$Map3IntroduceEntityFromJson(Map<String, dynamic> json) {
  return Map3IntroduceEntity(
    json['create_min'] as String,
    json['days'] as int,
    json['fee_max'] as String,
    json['fee_min'] as String,
    json['start_min'] as String,
    json['title'] as String,
    json['version'] as String,
    json['delegate_min'] as String,
  );
}

Map<String, dynamic> _$Map3IntroduceEntityToJson(
        Map3IntroduceEntity instance) =>
    <String, dynamic>{
      'create_min': instance.createMin,
      'days': instance.days,
      'fee_max': instance.feeMax,
      'fee_min': instance.feeMin,
      'start_min': instance.startMin,
      'title': instance.title,
      'version': instance.version,
      'delegate_min': instance.delegateMin,
    };
