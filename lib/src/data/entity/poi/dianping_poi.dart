import 'package:mapbox_gl/mapbox_gl.dart';
import 'poi_interface.dart';

class DianPingPoi implements IPoi {
  @override
  String address;

  @override
  String name;

  @override
  String remark;

  @override
  LatLng latLng;

  String shopName;
  String dealGroupTitle;
  String dealgroupPrice;
  String marketPrice;
  String defaultPic;
  String salesdesc;
  String schema;

  @override
  String toString() {
    return 'DianPingPoi{address: $address, name: $name, remark: $remark, latLng: $latLng, shopName: $shopName, dealGroupTitle: $dealGroupTitle, dealgroupPrice: $dealgroupPrice, marketPrice: $marketPrice, defaultPic: $defaultPic, salesdesc: $salesdesc, schema: $schema}';
  }


}
