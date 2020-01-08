import 'package:image_pickers/Media.dart';
import 'package:titan/src/business/position/model/poi_collector.dart';

class PoiDataModel {

  List<Media> listImagePaths = List();

  PoiCollector poiCollector;

  PoiDataModel({this.listImagePaths, this.poiCollector});
}