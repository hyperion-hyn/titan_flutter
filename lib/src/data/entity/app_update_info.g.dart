// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_update_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUpdateInfo _$AppUpdateInfoFromJson(Map<String, dynamic> json) {
  return AppUpdateInfo(
    json['need_update'] as int,
    json['new_version'] == null
        ? null
        : New_version.fromJson(json['new_version'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$AppUpdateInfoToJson(AppUpdateInfo instance) =>
    <String, dynamic>{
      'need_update': instance.needUpdate,
      'new_version': instance.newVersion,
    };

New_version _$New_versionFromJson(Map<String, dynamic> json) {
  return New_version(
    json['channel'] as String,
    json['describe'] as String,
    json['force'] as int,
    json['status'] as int,
    json['url_install'] as String,
    json['url_jump'] as String,
    json['version_code'] as int,
    json['version_name'] as String,
    json['version_type'] as String,
  );
}

Map<String, dynamic> _$New_versionToJson(New_version instance) =>
    <String, dynamic>{
      'channel': instance.channel,
      'describe': instance.describe,
      'force': instance.force,
      'status': instance.status,
      'url_install': instance.urlInstall,
      'url_jump': instance.urlJump,
      'version_code': instance.versionCode,
      'version_name': instance.versionName,
      'version_type': instance.versionType,
    };
