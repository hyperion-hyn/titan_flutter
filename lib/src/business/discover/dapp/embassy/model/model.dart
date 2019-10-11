import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/model/poi_interface.dart';

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

  @override
  String toString() {
    return 'EmbassyPoi{address: $address, name: $name, remark: $remark, department: $department, website: $website, telephone: $telephone, latLng: $latLng, id: $id}';
  }
}
