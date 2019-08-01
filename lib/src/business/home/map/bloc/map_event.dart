import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:meta/meta.dart';

@immutable
abstract class MapEvent {}

///marker
class AddMarkerEvent extends MapEvent {
  final LatLng coordinate;

  AddMarkerEvent({this.coordinate});
}

class ClearMarkerEvent extends MapEvent {}


///marker list
class AddMarkerListEvent extends MapEvent {
  final List<dynamic> pois;

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
