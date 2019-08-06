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
class AddRouteEvent extends MapEvent {
  final dynamic routeData;

  AddRouteEvent({this.routeData});
}

class ClearRouteEvent extends MapEvent {}


///location
class MyLocationEvent extends MapEvent {}
