import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:meta/meta.dart';

@immutable
abstract class MapState {}

class InitialMapState extends MapState {}


///marker
class MarkerLoadedState extends MapState {
  final LatLng coordinate;

  MarkerLoadedState({this.coordinate});
}

class ClearMarkerState extends MapState {}


///marker list
class MarkerListLoadedState extends MapState {
  final List<dynamic> pois;

  MarkerListLoadedState({this.pois});
}

class ClearMarkerListState extends MapState {}

///route
class RouteLoadedState extends MapState {
  final dynamic routeData;

  RouteLoadedState({this.routeData});
}

class ClearRouteState extends MapState {}


///location
class MyLocationState extends MapState {}
