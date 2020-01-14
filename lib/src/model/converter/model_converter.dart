import 'package:mapbox_gl/mapbox_gl.dart';

class LatLngConverter {
  static LatLng latLngFromJson(dynamic json) {
    return LatLng(json[0], json[1]);
  }

  static dynamic latLngToJson(LatLng latLng) {
    return <double>[latLng.latitude, latLng.longitude];
  }
}

class LocationConverter {
  static LatLng latLngFromJson(dynamic json) {
    return LatLng(json['coordinates'][0], json['coordinates'][1]);
  }

  static dynamic latLngToJson(LatLng latLng) {
    var latlng = <double>[latLng.latitude, latLng.longitude];
    var l = {'coordinates': latlng};
    return l;
  }
}
