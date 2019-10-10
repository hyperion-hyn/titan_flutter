import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'purchased_map_item.g.dart';

@JsonSerializable()
@entity
class PurchasedMap {
  @primaryKey
  String id;
  String name;
  String description;
  String sourceUrl;
  String sourceLayer;
  String icon;
  String color;
  double minZoom;
  double maxZoom;
  bool selected;



  PurchasedMap(this.id, this.name, this.description, this.sourceUrl, this.sourceLayer, this.icon, this.color,
      this.minZoom, this.maxZoom, this.selected);

  factory PurchasedMap.fromJson(Map<String, dynamic> json) => _$PurchasedMapFromJson(json);

  Map<String, dynamic> toJson() => _$PurchasedMapToJson(this);
}
