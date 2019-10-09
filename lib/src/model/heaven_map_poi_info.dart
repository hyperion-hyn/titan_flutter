import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/model/poi_interface.dart';

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

  @override
  String toString() {
    return 'HeavenMapPoiInfo{id: $id, time: $time, phone: $phone, service: $service, desc: $desc, area: $area, address: $address, name: $name, remark: $remark, latLng: $latLng}';
  }


}
