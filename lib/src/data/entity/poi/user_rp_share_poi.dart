import 'package:json_annotation/json_annotation.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/data/entity/converter/model_converter.dart';
import 'package:titan/src/data/entity/poi/poi_interface.dart';
import 'package:titan/src/data/entity/poi/user_contribution_poi.dart';

part 'user_rp_share_poi.g.dart';


@JsonSerializable()
class UserRpSharePoi extends Object implements IPoi{

  @JsonKey(name: 'id')
  String id;

  UserRpSharePoi(this.id, this.latLng);

  factory UserRpSharePoi.fromJson(Map<String, dynamic> srcJson) => _$UserRpSharePoiFromJson(srcJson);

  Map<String, dynamic> toJson() => _$UserRpSharePoiToJson(this);

  @override
  String address;

  @override
  String name;

  @override
  String remark;

  @override
  LatLng latLng;

}