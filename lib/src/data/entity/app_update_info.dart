import 'package:json_annotation/json_annotation.dart';

part 'app_update_info.g.dart';


@JsonSerializable()
class AppUpdateInfo extends Object {

  @JsonKey(name: 'need_update')
  int needUpdate;

  @JsonKey(name: 'new_version')
  New_version newVersion;

  AppUpdateInfo(this.needUpdate,this.newVersion,);

  factory AppUpdateInfo.fromJson(Map<String, dynamic> srcJson) => _$AppUpdateInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AppUpdateInfoToJson(this);

}


@JsonSerializable()
class New_version extends Object {

  @JsonKey(name: 'channel')
  String channel;

  @JsonKey(name: 'describe')
  String describe;

  @JsonKey(name: 'force')
  int force;

  @JsonKey(name: 'status')
  int status;

  @JsonKey(name: 'url_install')
  String urlInstall;

  @JsonKey(name: 'url_jump')
  String urlJump;

  @JsonKey(name: 'version_code')
  int versionCode;

  @JsonKey(name: 'version_name')
  String versionName;

  @JsonKey(name: 'version_type')
  String versionType;

  New_version(this.channel,this.describe,this.force,this.status,this.urlInstall,this.urlJump,this.versionCode,this.versionName,this.versionType,);

  factory New_version.fromJson(Map<String, dynamic> srcJson) => _$New_versionFromJson(srcJson);

  Map<String, dynamic> toJson() => _$New_versionToJson(this);

}


