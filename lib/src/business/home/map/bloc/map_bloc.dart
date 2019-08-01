import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import './bloc.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final BuildContext context;

  MapBloc({this.context});

  @override
  MapState get initialState => InitialMapState();

  @override
  Stream<MapState> mapEventToState(MapEvent event) async* {
    if (event is AddMarkerEvent) {
      yield MarkerLoadedState(coordinate: event.coordinate);
    } else if (event is ClearMarkerEvent) {
      yield ClearMarkerState();
    } else if (event is AddRouteEvent) {
      yield RouteLoadedState(routeData: event.routeData);
    } else if (event is ClearRouteEvent) {
      yield ClearRouteState();
    } else if (event is MyLocationEvent) {
      yield MyLocationState();
    }
  }
}
