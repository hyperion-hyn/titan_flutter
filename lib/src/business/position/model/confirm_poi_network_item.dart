import 'package:json_annotation/json_annotation.dart';

import 'confirm_poi_item.dart';

part 'confirm_poi_network_item.g.dart';


@JsonSerializable()
class ConfirmPoiNetworkItem extends Object {

  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'location')
  Location location;

  @JsonKey(name: 'Properties')
  Properties properties;

  ConfirmPoiNetworkItem(this.id,this.location,this.properties,);

  factory ConfirmPoiNetworkItem.fromJson(Map<String, dynamic> srcJson) => _$ConfirmPoiNetworkItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ConfirmPoiNetworkItemToJson(this);

}


/*@JsonSerializable()
class Location extends Object {

  @JsonKey(name: 'coordinates')
  List<double> coordinates;

  @JsonKey(name: 'type')
  String type;

  Location(this.coordinates,this.type,);

  factory Location.fromJson(Map<String, dynamic> srcJson) => _$LocationFromJson(srcJson);

  Map<String, dynamic> toJson() => _$LocationToJson(this);

}*/


@JsonSerializable()
class Properties extends Object {

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'category')
  String category;

  @JsonKey(name: 'ext')
  String ext;

  @JsonKey(name: 'state')
  int state;

  @JsonKey(name: 'phone')
  String phone;

  @JsonKey(name: 'work_time')
  String workTime;

  Properties(this.name,this.address,this.category,this.ext,this.state,this.phone,this.workTime,);

  factory Properties.fromJson(Map<String, dynamic> srcJson) => _$PropertiesFromJson(srcJson);

  Map<String, dynamic> toJson() => _$PropertiesToJson(this);

}