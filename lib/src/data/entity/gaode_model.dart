import './gaode_poi.dart';

class GaodeModel {
  int page;
  List<GaodePoi> data;
  int totalPage;

  GaodeModel({this.data, this.page, this.totalPage});

  @override
  String toString() {
    return 'GaodeModel{page: $page, data: $data, totalPage: $totalPage}';
  }


}
