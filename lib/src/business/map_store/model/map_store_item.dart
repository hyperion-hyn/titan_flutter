import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/business/map_store/model/location.dart';
import 'package:titan/src/business/map_store/model/map_store_item_config.dart';
import 'package:titan/src/business/map_store/model/map_store_item_policy.dart';

part 'map_store_item.g.dart';

@JsonSerializable()
class MapStoreItem {
  String id;
  String title;
  @JsonKey(name: "map_name")
  String mapName;
  @JsonKey(name: "layer_name")
  String layerName;
  List<String> categories;
  List<MapStoreItemPolicy> policies;
  Location location;
  String publisher;
  @JsonKey(name: "created_on")
  int createdOn;
  @JsonKey(name: "modified_on")
  int modifiedOn;
  String preview;
  String description;
  @JsonKey(name: "tile_url")
  String titleUrl;
  MapStoreItemConfig config;
  String showPrice;
  bool isFree;
  bool isPurchased;
  bool isShowMore = false;


  MapStoreItem();

  factory MapStoreItem.fromJson(Map<String, dynamic> json) => _$MapStoreItemFromJson(json);
  Map<String, dynamic> toJson() => _$MapStoreItemToJson(this);
}
