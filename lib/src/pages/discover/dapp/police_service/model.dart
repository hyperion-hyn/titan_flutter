import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/data/entity/poi/poi_interface.dart';

class PoliceStationPoi implements IDMapPoi {
  @override
  String address;

  @override
  String name;

  @override
  String remark;

  @override
  LatLng latLng;


  ///部门
  String department;
  ///电话
  String telephone;
  ///地区
  String district;

  String id;

  PoliceStationPoi();

  factory PoliceStationPoi.fromMapFeature(Map<String, dynamic> feature) {
    PoliceStationPoi poi = PoliceStationPoi();

    poi.id = feature["id"] is int ? feature["id"].toString() : feature["id"];
    var lat = feature["geometry"]["coordinates"][1];
    var lon = feature["geometry"]["coordinates"][0];
    poi.latLng = LatLng(lat, lon);
    poi.name = feature["properties"]["name"];
    poi.telephone = feature["properties"]["telephone"];
    poi.department = feature["properties"]["department"];
    poi.district = feature["properties"]["district"];
    poi.remark = feature["properties"]["remark"];
    poi.address = feature["properties"]["address"];

    return poi;
  }
}