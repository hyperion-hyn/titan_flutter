import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/business/contribution/vo/latlng.dart';

part 'poi_collector.g.dart';


@JsonSerializable()
class PoiCollector extends Object {

  @JsonKey(name: 'category_id')
  String categoryId;

  @JsonKey(name: 'location')
  LatLng location;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'country')
  String country;

  @JsonKey(name: 'state')
  String state;

  @JsonKey(name: 'city')
  String city;

  @JsonKey(name: 'address_1')
  String address1;

  @JsonKey(name: 'address_2')
  String address2;

  @JsonKey(name: 'number')
  String number;

  @JsonKey(name: 'postal_code')
  String postalCode;

  @JsonKey(name: 'work_time')
  String workTime;

  @JsonKey(name: 'phone')
  String phone;

  @JsonKey(name: 'website')
  String website;

  PoiCollector(this.categoryId,this.location,this.name,this.country,this.state,this.city,this.address1,this.address2,this.number,this.postalCode,this.workTime,this.phone,this.website,);

  factory PoiCollector.fromJson(Map<String, dynamic> srcJson) => _$PoiCollectorFromJson(srcJson);

  Map<String, dynamic> toJson() => _$PoiCollectorToJson(this);

}




