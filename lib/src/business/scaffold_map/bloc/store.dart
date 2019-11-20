import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/business/scaffold_map/dmap/dmap.dart';
import 'package:titan/src/model/poi_interface.dart';

class ScaffoldMapStore {
  IPoi currentPoi;

  String searchText;
  List<IPoi> searchPoiList = [];

  DMapConfigModel dMapConfigModel;

  ScaffoldMapStore._();

  static final ScaffoldMapStore shared = ScaffoldMapStore._();

  void clearAll() {
    currentPoi = null;
    searchText = null;
    searchPoiList = [];
    dMapConfigModel = null;
  }
}
