import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/model/poi_interface.dart';

@immutable
abstract class MapEvent {}

///marker
class AddMarkerEvent extends MapEvent {
  final IPoi poi;

  AddMarkerEvent({this.poi});
}

class ClearMarkerEvent extends MapEvent {}


///marker list
class AddMarkerListEvent extends MapEvent {
  final List<IPoi> pois;

  AddMarkerListEvent({this.pois});
}

class ClearMarkerListEvent extends MapEvent {}

///route
class QueryRouteEvent extends MapEvent {
  final LatLng start;
  final LatLng end;
  final String languageCode;
  final int padding;
  final String profile;
  final String startName;
  final String endName;
  final IPoi selectedPoi;

  QueryRouteEvent({
    this.start,
    this.end,
    this.languageCode,
    this.profile = 'driving',
    this.startName,
    this.endName,
    this.selectedPoi,
    this.padding = 100,
  });
}

class CloseRouteEvent extends MapEvent {}


///location
class MyLocationEvent extends MapEvent {}
