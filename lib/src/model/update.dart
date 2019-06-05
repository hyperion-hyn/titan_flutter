import 'package:json_annotation/json_annotation.dart';

part 'update.g.dart';

@JsonSerializable()
class UpdateEntity {
  final int build;
  @JsonKey(name: 'version_name')
  final String versionName;
  final String content;
  @JsonKey(name: 'force_update')
  final int forceUpdate;
  final String md5;
  @JsonKey(name: 'download_url')
  final String downloadUrl;

  UpdateEntity({this.build, this.versionName, this.content, this.forceUpdate, this.md5, this.downloadUrl});

  factory UpdateEntity.fromJson(Map<String, dynamic> json) => _$UpdateEntityFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateEntityToJson(this);
}
