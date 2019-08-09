import 'package:mapbox_gl/mapbox_gl.dart';

abstract class IPoi {
  final LatLng latLng;
  String name;

  IPoi({this.latLng, this.name});
}
