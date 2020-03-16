import 'package:mapbox_gl/mapbox_gl.dart';
import 'poi_interface.dart';

class SimplePoiWithPhoto implements IPoi {
  @override
  String address;

  @override
  String name;

  @override
  String remark;

  @override
  LatLng latLng;

  String photo;

  SimplePoiWithPhoto({
    this.latLng,
    this.name,
    this.address,
    this.remark,
    this.photo,
  });

  factory SimplePoiWithPhoto.fromJson(Map<String, dynamic> json) {
    var poi = SimplePoiWithPhoto();
    poi.address = json['address'];
    poi.name = json['name'];
    poi.photo = json['photo'];
    poi.latLng = LatLng(json['lat'], json['lon']);
    return poi;
  }

  factory SimplePoiWithPhoto.fromGJson(Map<String, dynamic> json) {
    var poi = SimplePoiWithPhoto();

    var location = json['geometry']["location"];
    var lat = location['lat'];
    var lon = location['lng'];
    poi.latLng = LatLng(lat, lon);

    poi.address = json['vicinity'];
    poi.name = json['name'];
    var photos = json["photos"];
    if (photos != null) {
      var firstPhoto = photos[0];
      var photoReference = firstPhoto["photo_reference"];
      poi.photo =
          "https://api.hyn.space/titan-map/api/place/photo?maxwidth=400&photoreference=$photoReference&key=AIzaSyBso8NrJV0RREGd-R6jikaqRnp4djmplCc";
    } else {
      poi.photo = "";
    }

    return poi;
  }
}
