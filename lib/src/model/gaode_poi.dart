import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/model/poi_interface.dart';

class GaodePoi implements IPoi {
  @override
  String address;

  @override
  String name;

  @override
  String remark;

  @override
  LatLng latLng;

  String photo;

  GaodePoi({
    this.latLng,
    this.name,
    this.address,
    this.remark,
    this.photo,
  });

  factory GaodePoi.fromJson(Map<String, dynamic> json) {
    var poi = GaodePoi();
    poi.address = json['address'];
    poi.name = json['name'];
    poi.photo = json['photo'];
    poi.latLng = LatLng(json['lat'], json['lon']);
    return poi;
  }
}
