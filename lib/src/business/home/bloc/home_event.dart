import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/model/heaven_map_poi_info.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/model/poi_interface.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

@immutable
abstract class HomeEvent {}

class ShowPoiEvent extends HomeEvent {
  final IPoi poi;

  ShowPoiEvent({this.poi});
}

class SearchPoiEvent extends HomeEvent {
  final IPoi poi;

  SearchPoiEvent({this.poi});
}

class SearchHeavenPoiEvent extends HomeEvent {
  final HeavenMapPoiInfo poi;

  SearchHeavenPoiEvent({this.poi});
}

class SearchTextEvent extends HomeEvent {
  final String searchText;
  final LatLng center;

//  final List<dynamic> pois;

  SearchTextEvent({this.center, this.searchText});

  @override
  String toString() {
    return 'SearchPoiEvent{searchText: $searchText, center: $center}';
  }
}

class ExistSearchEvent extends HomeEvent {}

//route
//class RouteEvent extends HomeEvent {}

//event bus
class RouteClickEvent extends HomeEvent {
  final String profile;
  final IPoi toPoi;

  RouteClickEvent({
    this.profile = 'driving',
    this.toPoi,
  });
}

class MapOperatingEvent extends HomeEvent {
}

class HomeInitEvent extends HomeEvent {
}