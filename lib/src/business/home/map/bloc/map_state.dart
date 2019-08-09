import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/model/poi_interface.dart';

@immutable
abstract class MapState {}

class InitialMapState extends MapState {}


///marker
class MarkerLoadedState extends MapState {
  final IPoi poi;

  MarkerLoadedState({this.poi});
}

class ClearMarkerState extends MapState {}


///marker list
class MarkerListLoadedState extends MapState {
  final List<dynamic> pois;

  MarkerListLoadedState({this.pois});
}

class ClearMarkerListState extends MapState {}

///route
class RouteSceneState extends MapState {
  final RouteDataModel routeDataModel;
  final bool isLoading;
  final bool isError;
  final String startName;
  final String endName;
  final String profile;
  final IPoi selectedPoi;

  RouteSceneState({
    this.routeDataModel,
    this.isLoading = false,
    this.isError = false,
    this.endName,
    this.startName,
    this.profile,
    this.selectedPoi,
  });

  RouteSceneState copyWith(RouteSceneState copy) {
    return RouteSceneState(
        routeDataModel: copy.routeDataModel ?? this.routeDataModel,
        profile: copy.profile ?? this.profile,
        startName: copy.startName ?? this.startName,
        endName: copy.endName ?? this.endName,
        isError: copy.isError ?? this.isError,
        selectedPoi: copy.selectedPoi ?? this.selectedPoi,
        isLoading: copy.isLoading ?? this.isLoading);
  }

  @override
  String toString() {
    return 'RouteSceneState(isLoading: $isLoading, isError: $isError, routeDataModel: $routeDataModel)';
  }
}

class CloseRouteState extends MapState {}



///location
//class MyLocationState extends MapState {}
