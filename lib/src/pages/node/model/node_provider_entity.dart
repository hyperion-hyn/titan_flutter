import 'dart:ffi';

import 'package:json_annotation/json_annotation.dart';

part 'node_provider_entity.g.dart';

@JsonSerializable()
class NodeProviderEntity extends Object {
  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'regions')
  List<Regions> regions;

  NodeProviderEntity(
    this.id,
    this.name,
    this.regions,
  );

  factory NodeProviderEntity.fromJson(Map<String, dynamic> srcJson) =>
      _$NodeProviderEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$NodeProviderEntityToJson(this);
}

@JsonSerializable()
class Regions extends Object {
  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'location')
  Location location;

  Regions(
    this.id,
    this.name,
    this.location,
  );

  factory Regions.fromJson(Map<String, dynamic> srcJson) =>
      _$RegionsFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RegionsToJson(this);
}

@JsonSerializable()
class Location extends Object {
  @JsonKey(name: 'coordinates')
  List<double> coordinates;

  @JsonKey(name: 'type')
  String type;

  Location(
    this.coordinates,
    this.type,
  );

  factory Location.fromJson(Map<String, dynamic> srcJson) =>
      _$LocationFromJson(srcJson);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}
