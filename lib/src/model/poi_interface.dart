import 'package:mapbox_gl/mapbox_gl.dart';

abstract class IPoi {
  String name;
  final String address;
  final LatLng latLng;

  IPoi({
    this.latLng,
    this.name,
    this.address,
  });
}
