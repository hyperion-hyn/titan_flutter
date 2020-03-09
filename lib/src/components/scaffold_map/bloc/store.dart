import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/data/entity/poi_interface.dart';

import '../dmap/dmap.dart';

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
