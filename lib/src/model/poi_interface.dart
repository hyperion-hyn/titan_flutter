import 'package:mapbox_gl/mapbox_gl.dart';

abstract class IPoi {
  String name;
  String address;
  String remark;
  final LatLng latLng;


  IPoi({
    this.latLng,
    this.name,
    this.address,
    this.remark,
  });
}


abstract class IDMapPoi extends IPoi {
}