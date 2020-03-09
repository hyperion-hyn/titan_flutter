import 'package:mapbox_gl/mapbox_gl.dart';
import './poi_interface.dart';

class HeavenMapPoiInfo implements IDMapPoi {
  String id;
  String time;
  String phone;
  String service;
  String desc;
  String area;

  @override
  String address;

  @override
  String name;

  @override
  String remark;

  @override
  LatLng latLng;

  HeavenMapPoiInfo();

  factory HeavenMapPoiInfo.fromMapFeature(Map<String, dynamic> feature) {
    HeavenMapPoiInfo poi = HeavenMapPoiInfo();

    poi.id = feature["id"] is int ? feature["id"].toString() : feature["id"];
    var lat = double.parse(feature["properties"]["lat"]);
    var lon = double.parse(feature["properties"]["lon"]);
    poi.latLng = LatLng(lat, lon);
    poi.time = feature["properties"]["time"];
    poi.phone = feature["properties"]["telephone"];
    poi.service = feature["properties"]["service"];
    poi.address = feature["properties"]["address"];
    poi.desc = feature["properties"]["desc"];
    poi.name = feature["properties"]["name"];
    poi.area = feature["properties"]["area"];

    return poi;
  }

  @override
  String toString() {
    return 'HeavenMapPoiInfo{id: $id, time: $time, phone: $phone, service: $service, desc: $desc, area: $area, address: $address, name: $name, remark: $remark, latLng: $latLng}';
  }


}
