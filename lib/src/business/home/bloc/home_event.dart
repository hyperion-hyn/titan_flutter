import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

import '../../../store.dart';

@immutable
abstract class HomeEvent {}

/// home search
class ClearSearchMode extends HomeEvent {}

class SearchPoiListEvent extends HomeEvent {
  final String searchText;
  final String center;
  final String language;

  SearchPoiListEvent({this.searchText, this.center, this.language});
}

/// bottom sheet
class ClosePoiBottomSheetEvent extends HomeEvent {}

class SelectedPoiEvent extends HomeEvent {
  final dynamic selectedPoi;
  final DraggableBottomSheetState state;

  SelectedPoiEvent({this.selectedPoi, this.state});
}

/// route
class QueryRouteEvent extends HomeEvent {
  final LatLng start;
  final LatLng end;
  final String languageCode;
  final int padding = 100;
  final String profile;
  final String startName;
  final String endName;
  final PoiEntity selectedPoi;

  QueryRouteEvent({
    this.start,
    this.end,
    this.languageCode,
    this.profile = 'driving',
    this.startName,
    this.endName,
    this.selectedPoi,
  });
}

class CloseRouteEvent extends HomeEvent {}

/// action event
class MyLocationClickEvent extends HomeEvent {}

class RouteClickEvent extends HomeEvent {}
