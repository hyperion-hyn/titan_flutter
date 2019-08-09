import 'package:json_annotation/json_annotation.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'converter/model_converter.dart';
import 'poi_interface.dart';

//see more example https://github.com/dart-lang/json_serializable/blob/master/example/lib/json_converter_example.dart

part 'poi.g.dart';

@JsonSerializable()
class PoiEntity implements IPoi {
  String name;
  final String address;
  final String tags;
  @JsonKey(fromJson: LatLngConverter.latLngFromJson, toJson: LatLngConverter.latLngToJson)
  final LatLng latLng;
  final String phone;
  final String remark;
  @JsonKey(ignore: true)
  bool isHistory;

  PoiEntity({this.name, this.address, this.tags, this.latLng, this.phone, this.remark, this.isHistory});

  factory PoiEntity.fromJson(Map<String, dynamic> json) => _$PoiEntityFromJson(json);

  Map<String, dynamic> toJson() => _$PoiEntityToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
