import 'package:json_annotation/json_annotation.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
part 'poi_collector.g.dart';


@JsonSerializable()
class PoiCollector extends Object {

  @JsonKey(name: 'category_id')
  String categoryId;

  @JsonKey(name: 'location')
  LatLng location;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'country_code')
  String countryCode;

  @JsonKey(name: 'country')
  String country;

  @JsonKey(name: 'state')
  String state;

  @JsonKey(name: 'city')
  String city;

  @JsonKey(name: 'road')
  String road;

  @JsonKey(name: 'address_2')
  String address2;

  @JsonKey(name: 'house_number')
  String houseNumber;

  @JsonKey(name: 'postal_code')
  String postalCode;

  @JsonKey(name: 'work_time')
  String workTime;

  @JsonKey(name: 'phone')
  String phone;

  @JsonKey(name: 'website')
  String website;

  PoiCollector(this.categoryId,this.location,this.name, this.countryCode,this.country,this.state,this.city,this.road,this.address2,this.houseNumber,this.postalCode,this.workTime,this.phone,this.website);

  factory PoiCollector.fromJson(Map<String, dynamic> srcJson) => _$PoiCollectorFromJson(srcJson);

  Map<String, dynamic> toJson() => _$PoiCollectorToJson(this);

}


/*
    PoiCollector(
        this.categoryId,
        this.location,
        this.name,
        this.countryCode,
        this.country,
        this.state,
        this.city,
        this.road,
        this.address2,
        this.houseNumber,
        this.postalCode,
        this.workTime,
        this.phone,
        this.website);
    */





