import 'package:json_annotation/json_annotation.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/data/entity/converter/model_converter.dart';
import 'package:titan/src/data/entity/poi/poi_interface.dart';

import './search_history_aware_poi.dart';

part 'user_contribution_poi.g.dart';

@JsonSerializable()
class UserContributionPoi with SearchHistoryAwarePoi implements IPoi {
  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'category')
  String category;

  @JsonKey(name: 'location')
  Location location;

  @JsonKey(name: 'ext')
  String ext;

  @JsonKey(name: 'state')
  int state;

  @JsonKey(name: 'phone')
  String phone;

  @JsonKey(name: 'work_time')
  String workTime;

  @JsonKey(name: 'images')
  List<String> images;

  @JsonKey(name: 'postcode')
  String postcode;

  @JsonKey(name: 'website')
  String website;

  @JsonKey(name: 'myself')
  bool myself;

  UserContributionPoi.empty();

  UserContributionPoi(this.id, this.name, this.address, this.category, this.location, this.ext, this.state, this.phone,
      this.workTime, this.images, this.postcode, this.website, this.myself);

  UserContributionPoi.onlyId(this.id);

  factory UserContributionPoi.fromJson(Map<String, dynamic> srcJson) => _$UserContributionPoiFromJson(srcJson);

  Map<String, dynamic> toJson() => _$UserContributionPoiToJson(this);

  @override
  String remark;

  @override
  LatLng get latLng {
    if (location?.coordinates != null) {
      return LatLng(location.coordinates[1], location.coordinates[0]);
    }
    return null;
  }

  UserContributionPoi.setPid(this.id, this.location);
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

  factory Location.fromJson(Map<String, dynamic> srcJson) => _$LocationFromJson(srcJson);

  Map<String, dynamic> toJson() => _$LocationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

@JsonSerializable()
class UserContributionPois extends Object {
  @JsonKey(name: 'coordinates')
  List<double> coordinates;

  @JsonKey(name: 'pois')
  List<UserContributionPoi> pois;

  UserContributionPois(
    this.coordinates,
    this.pois,
  );

  Map<String, dynamic> toJson() => _$UserContributionPoisToJson(this);

  factory UserContributionPois.fromJson(Map<String, dynamic> srcJson) => _$UserContributionPoisFromJson(srcJson);

  @override
  String toString() {
    return toJson().toString();
  }
}
