import 'package:titan/src/data/entity/poi/poi_interface.dart';

import '../dmap/dmap.dart';

class ScaffoldMapStore {
  IPoi currentPoi;

  String searchText;
  List<IPoi> searchPoiList = [];

  DMapConfigModel dMapConfigModel;

  void clear() {
    currentPoi = null;
    searchText = null;
    searchPoiList = [];
    dMapConfigModel = null;
  }
}
