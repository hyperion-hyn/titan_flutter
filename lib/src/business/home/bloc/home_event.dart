import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/model/poi_interface.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

@immutable
abstract class HomeEvent {}

class ClearSelectPoiEvent extends HomeEvent {}

class ShowPoiEvent extends HomeEvent {
  final IPoi poi;

  ShowPoiEvent({this.poi});
}

class SearchPoiEvent extends HomeEvent {
  final IPoi poi;

  SearchPoiEvent({this.poi});
}

class SearchTextEvent extends HomeEvent {
  final String searchText;
  final LatLng center;
  final List<dynamic> pois;

  SearchTextEvent({this.center, this.searchText, this.pois});

  @override
  String toString() {
    return 'SearchPoiEvent{searchText: $searchText, center: $center, pois:$pois}';
  }
}

class ExistSearchEvent extends HomeEvent {}
