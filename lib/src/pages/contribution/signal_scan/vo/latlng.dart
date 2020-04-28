import 'package:json_annotation/json_annotation.dart';

part 'latlng.g.dart';

@JsonSerializable()
class LatLng {
  @JsonKey(name: "lat")
  double lat;
  @JsonKey(name: "lon")
  double lon;

  LatLng(this.lat, this.lon);

  factory LatLng.fromJson(Map<String, dynamic> json) => _$LatLngFromJson(json);

  Map<String, dynamic> toJson() => _$LatLngToJson(this);
}
