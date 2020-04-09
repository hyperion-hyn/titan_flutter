import '../../data/entity/poi/photo_simple_poi.dart';

class PhotoPoiListResultModel {
  int page;
  List<SimplePoiWithPhoto> data;
  int totalPage;

  PhotoPoiListResultModel({this.data, this.page, this.totalPage});

  @override
  String toString() {
    return 'GaodeModel{page: $page, data: $data, totalPage: $totalPage}';
  }
}
