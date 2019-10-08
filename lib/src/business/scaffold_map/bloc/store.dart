import 'package:titan/src/model/poi_interface.dart';

class ScaffoldMapStore {
  IPoi currentPoi;

  String searchText;
  List<IPoi> searchPoiList = [];

  String dMapName;

  ScaffoldMapStore._();

  static final ScaffoldMapStore shared = ScaffoldMapStore._();

  void clearAll() {
    currentPoi = null;
    searchText = null;
    dMapName = null;
    searchPoiList = [];
  }
}
