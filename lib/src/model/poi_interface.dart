import 'package:mapbox_gl/mapbox_gl.dart';

abstract class IPoi {
  final String name;
  final String address;
  final LatLng latLng;

  IPoi({
    this.latLng,
    this.name,
    this.address,
  });
}
