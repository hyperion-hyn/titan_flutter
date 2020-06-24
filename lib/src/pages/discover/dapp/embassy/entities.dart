import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/data/entity/poi/poi_interface.dart';

class EmbassyPoi implements IDMapPoi {
  @override
  String address;

  @override
  String name;

  @override
  String remark;

  ///部门
  String department;

  ///官网
  String website;

  ///电话
  String telephone;

  @override
  LatLng latLng;

  String id;

  EmbassyPoi();

  factory EmbassyPoi.fromMapFeature(Map<String, dynamic> feature) {
    EmbassyPoi poi = EmbassyPoi();

    poi.id = feature["id"] is int ? feature["id"].toString() : feature["id"];
//    var lat = double.parse(feature["properties"]["lat"]);
//    var lon = double.parse(feature["properties"]["lon"]);
    var lat = feature["geometry"]["coordinates"][1];
    var lon = feature["geometry"]["coordinates"][0];
    poi.latLng = LatLng(lat, lon);
    poi.name = feature["properties"]["name"];
    poi.telephone = feature["properties"]["telephone"];
    poi.department = feature["properties"]["department"];
    poi.website = feature["properties"]["website"];
    poi.remark = feature["properties"]["remark"];
    poi.address = feature["properties"]["address"];

    return poi;
  }

  @override
  String toString() {
    return 'EmbassyPoi{address: $address, name: $name, remark: $remark, department: $department, website: $website, telephone: $telephone, latLng: $latLng, id: $id}';
  }
}
