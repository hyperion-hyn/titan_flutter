import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/business/home/bloc/bloc.dart' as home;
import 'package:titan/src/business/home/sheets/bloc/bloc.dart' as sheets;
import './bloc.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  BuildContext context;

  home.HomeBloc homeBloc;
  sheets.SheetsBloc sheetsBloc;

  MapBloc({this.context});

  @override
  MapState get initialState => InitialMapState();

  @override
  Stream<MapState> mapEventToState(MapEvent event) async* {
    if (event is AddMarkerEvent) {
      yield MarkerLoadedState(poi: event.poi);
    } else if (event is ClearMarkerEvent) {
      yield ClearMarkerState();
    } else if (event is AddMarkerListEvent) {
      yield MarkerListLoadedState(pois: event.pois);
    } else if (event is ClearMarkerListEvent) {
      yield ClearMarkerListState();
    } else if (event is QueryRouteEvent) {
      var routeState = RouteSceneState(
        isLoading: true,
        startName: event.startName,
        endName: event.endName,
        profile: event.profile,
        selectedPoi: event.selectedPoi,
      );
      yield routeState;

      try {
        String routeResp = await _fetchRoute(event.start, event.end, event.languageCode, profile: event.profile);
        var model = RouteDataModel(
          startLatLng: event.start,
          endLatLng: event.end,
          directionsResponse: routeResp,
          paddingRight: event.padding,
          paddingBottom: event.padding,
          paddingLeft: event.padding,
          paddingTop: event.padding,
        );

        yield routeState.copyWith(RouteSceneState(routeDataModel: model, isLoading: false)); //show route
      } catch (err) {
        print(err);
        yield routeState.copyWith(RouteSceneState(isError: true));
      }
    } else if (event is CloseRouteEvent) {
      yield CloseRouteState();
    } /*else if (event is MyLocationEvent) {
      yield MyLocationState();
    }*/
  }

  ///profile: driving, walking, cycling";
  Future<String> _fetchRoute(LatLng start, LatLng end, String language, {String profile = 'driving'}) async {
    var url =
        'https://api.hyn.space/directions/v5/hyperion/$profile/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=polyline6&language=$language&steps=true&banner_instructions=true&voice_instructions=true&voice_units=metric&access_token=pk.hyn';
    print(url);
    var httpClient = new HttpClient();
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    if (response.statusCode == HttpStatus.OK) {
      var responseBody = await response.transform(utf8.decoder).join();
      return responseBody;
    }
    throw Exception('fetch error');
  }
}
