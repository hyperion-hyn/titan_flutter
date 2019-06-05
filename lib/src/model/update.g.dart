// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateEntity _$UpdateEntityFromJson(Map<String, dynamic> json) {
  return UpdateEntity(
      build: json['build'] as int,
      versionName: json['version_name'] as String,
      content: json['content'] as String,
      forceUpdate: json['force_update'] as int,
      md5: json['md5'] as String,
      downloadUrl: json['download_url'] as String);
}

Map<String, dynamic> _$UpdateEntityToJson(UpdateEntity instance) =>
    <String, dynamic>{
      'build': instance.build,
      'version_name': instance.versionName,
      'content': instance.content,
      'force_update': instance.forceUpdate,
      'md5': instance.md5,
      'download_url': instance.downloadUrl
    };
