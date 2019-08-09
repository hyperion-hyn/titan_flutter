import 'package:mapbox_gl/mapbox_gl.dart';

abstract class IPoi {
  final LatLng latLng;
  final String name;

  IPoi({this.latLng, this.name});
}
