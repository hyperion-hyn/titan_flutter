import 'package:mapbox_gl/mapbox_gl.dart';

class LatLngConverter {
  static LatLng latLngFromJson(dynamic json) {
    return LatLng(json[0], json[1]);
  }

  static dynamic latLngToJson(LatLng latLng) {
    return <double>[latLng.latitude, latLng.longitude];
  }
}

/// convert location: {"location": {"lat": 111, "lon": 111}} to Mapbox LatLng
class LocationConverter {
  static LatLng latLngFromJson(dynamic json) {
    return LatLng(json['lat'], json['lon']);
  }

  static dynamic latLngToJson(LatLng latLng) {
//    var l = {
//      'location': {'lat': latLng.latitude, 'lon': latLng.longitude}
//    };
    var l = {'lat': latLng.latitude, 'lon': latLng.longitude};
    return l;
  }
}
