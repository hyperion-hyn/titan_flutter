import 'package:json_annotation/json_annotation.dart';

part 'purchased_map_item.g.dart';

@JsonSerializable()
class PurchasedMapItem {
  String id;
  String name;
  String description;
  String sourceUrl;
  String sourceLayer;
  String icon;
  int color;
  double minZoom;
  double maxZoom;
  bool selected;

  PurchasedMapItem();

  factory PurchasedMapItem.fromJson(Map<String, dynamic> json) => _$PurchasedMapItemFromJson(json);

  Map<String, dynamic> toJson() => _$PurchasedMapItemToJson(this);
}
