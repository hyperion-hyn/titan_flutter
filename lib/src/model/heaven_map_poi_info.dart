import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/model/poi_interface.dart';

class HeavenMapPoiInfo implements IPoi {
  String id;
  String time;
  String phone;
  String service;
  String desc;

  @override
  String address;

  @override
  String name;

  @override
  String remark;

  @override
  LatLng latLng;
}
