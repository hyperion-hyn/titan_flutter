import 'package:json_annotation/json_annotation.dart';


part "map_store_item_config.g.dart";

@JsonSerializable()
class MapStoreItemConfig {
  String icon;
  String color;
  @JsonKey(name: "min_zoom")
  double minZoom;
  @JsonKey(name: "max_zoom")
  double maxZoom;


  MapStoreItemConfig();

  factory MapStoreItemConfig.fromJson(Map<String, dynamic> json) => _$MapStoreItemConfigFromJson(json);
  Map<String, dynamic> toJson() => _$MapStoreItemConfigToJson(this);

}
