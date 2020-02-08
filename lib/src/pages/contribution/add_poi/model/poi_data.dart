import 'package:image_pickers/Media.dart';
import 'package:titan/src/pages/contribution/add_poi/model/poi_collector.dart';

class PoiDataModel {

  List<Media> listImagePaths = List();

  PoiCollector poiCollector;

  PoiDataModel({this.listImagePaths, this.poiCollector});
}