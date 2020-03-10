import 'package:image_pickers/Media.dart';
import 'package:titan/src/pages/discover/dapp/ncov/model/ncov_poi_entity.dart';
import 'package:titan/src/pages/contribution/add_poi/model/poi_collector.dart';

class PoiDataModel {
  List<Media> listImagePaths = List();

  PoiCollector poiCollector;

  PoiDataModel({this.listImagePaths, this.poiCollector});
}

class PoiNcovDataModel {
  List<Media> listImagePaths = List();

  NcovPoiEntity poiCollector;

  PoiNcovDataModel({this.listImagePaths, this.poiCollector});
}
