// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_post_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestPostEntity _$TestPostEntityFromJson(Map<String, dynamic> json) {
  return TestPostEntity(
    json['address'] as String,
    json['pub'] as String,
    json['ts'] as int,
    json['version'] as String,
  );
}

Map<String, dynamic> _$TestPostEntityToJson(TestPostEntity instance) =>
    <String, dynamic>{
      'address': instance.address,
      'pub': instance.pub,
      'ts': instance.ts,
      'version': instance.version,
    };
