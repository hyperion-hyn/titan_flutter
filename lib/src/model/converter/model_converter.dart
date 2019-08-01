import 'package:mapbox_gl/mapbox_gl.dart';

class LatLngConverter {
  static LatLng latLngFromJson(dynamic json) {
    return LatLng(json[0], json[1]);
  }

  static dynamic latLngToJson(LatLng latLng) {
    return <double>[latLng.latitude, latLng.longitude];
  }
}
