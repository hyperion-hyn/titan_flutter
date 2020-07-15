import 'package:json_annotation/json_annotation.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/data/entity/converter/model_converter.dart';

part 'poi_collector.g.dart';

@JsonSerializable()
class PoiCollector extends Object {
  @JsonKey(name: 'category_id')
  String categoryId;

  @JsonKey(fromJson: LocationConverter.latLngFromJson, toJson: LocationConverter.latLngToJson)
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

  @JsonKey(name: 'county')
  String county;

  @JsonKey(name: 'road')
  String road;

  @JsonKey(name: 'address_2')
  String address2;

  @JsonKey(name: 'house_number')
  String houseNumber;

  @JsonKey(name: 'postcode')
  String postCode;

  @JsonKey(name: 'work_time')
  String workTime;

  @JsonKey(name: 'phone')
  String phone;

  @JsonKey(name: 'website')
  String website;

  @JsonKey(name: 'category')
  String category;

  PoiCollector(this.categoryId, this.location, this.name, this.countryCode, this.country, this.state, this.city,
      this.county, this.road, this.address2, this.houseNumber, this.postCode, this.workTime, this.phone, this.website, this.category);

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
        this.county,
        this.road,
        this.address2,
        this.houseNumber,
        this.postalCode,
        this.workTime,
        this.phone,
        this.website);
    */
