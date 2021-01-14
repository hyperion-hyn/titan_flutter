import 'package:json_annotation/json_annotation.dart';

part 'user_rp_share_poi.g.dart';


@JsonSerializable()
class UserRpSharePoi extends Object {

  @JsonKey(name: 'id')
  String id;

  UserRpSharePoi(this.id,);

  factory UserRpSharePoi.fromJson(Map<String, dynamic> srcJson) => _$UserRpSharePoiFromJson(srcJson);

  Map<String, dynamic> toJson() => _$UserRpSharePoiToJson(this);

}