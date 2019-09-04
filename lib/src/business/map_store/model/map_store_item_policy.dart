import 'package:json_annotation/json_annotation.dart';

part 'map_store_item_policy.g.dart';

@JsonSerializable()
class MapStoreItemPolicy {
  String currency;
  double price;
  double duration;

  MapStoreItemPolicy();

  factory MapStoreItemPolicy.fromJson(Map<String, dynamic> json) => _$MapStoreItemPolicyFromJson(json);

  Map<String, dynamic> toJson() => _$MapStoreItemPolicyToJson(this);
}
