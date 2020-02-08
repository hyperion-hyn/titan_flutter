import 'package:json_annotation/json_annotation.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
  
part 'ncov_poi_entity.g.dart';


@JsonSerializable()
  class NcovPoiEntity extends Object {

  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'location')
  Location location;

  @JsonKey(name: 'images')
  List<String> images;

  @JsonKey(name: 'postcode')
  String postcode;

  @JsonKey(name: 'confirmed_count')
  int confirmedCount;

  @JsonKey(name: 'confirmed_type')
  String confirmedType;

  @JsonKey(name: 'isolation')
  String isolation;

  @JsonKey(name: 'isolation_house_type')
  String isolationHouseType;

  @JsonKey(name: 'symptoms')
  List<String> symptoms;

  @JsonKey(name: 'symptoms_detail')
  String symptomsDetail;

  @JsonKey(name: 'trip')
  String trip;

  @JsonKey(name: 'security_measures')
  String securityMeasures;

  @JsonKey(name: 'contact_records')
  String contactRecords;

  LatLng get latLng {
    if(location?.coordinates != null) {
      return LatLng(location.coordinates[1], location.coordinates[0]);
    }
    return null;
  }

  NcovPoiEntity(this.id,this.name,this.address,this.location,this.images,this.postcode,this.confirmedCount,this.confirmedType,this.isolation,this.isolationHouseType,this.symptoms,this.symptomsDetail,this.trip,this.securityMeasures,this.contactRecords,);

  factory NcovPoiEntity.fromJson(Map<String, dynamic> srcJson) => _$NcovPoiEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$NcovPoiEntityToJson(this);

}

  
@JsonSerializable()
  class Location extends Object {

  @JsonKey(name: 'coordinates')
  List<double> coordinates;

  @JsonKey(name: 'type')
  String type;

  Location(this.coordinates,this.type,);

  factory Location.fromJson(Map<String, dynamic> srcJson) => _$LocationFromJson(srcJson);

  Map<String, dynamic> toJson() => _$LocationToJson(this);

}

  
