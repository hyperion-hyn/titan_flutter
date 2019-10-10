import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/business/scaffold_map/dmap/dmap.dart';
import 'package:titan/src/inject/injector.dart';
import 'package:titan/src/model/poi.dart';
import '../../../global.dart';
import './bloc.dart';

class ScaffoldMapBloc extends Bloc<ScaffoldMapEvent, ScaffoldMapState> {
  final BuildContext context;

  ScaffoldMapBloc(this.context);

  @override
  ScaffoldMapState get initialState => InitialScaffoldMapState();

  @override
  Stream<ScaffoldMapState> transform(Stream<ScaffoldMapEvent> events,
      Stream<ScaffoldMapState> Function(ScaffoldMapEvent event) next) {
    return super.transform(events, next);
  }

  @override
  Stream<ScaffoldMapState> mapEventToState(ScaffoldMapEvent event) async* {
    if (event is InitMapEvent) {
      ScaffoldMapStore.shared.clearAll();
      yield InitialScaffoldMapState();
    }
    //--------------
    // poi
    //--------------
    /*search one poi*/
    else if (event is SearchPoiEvent) {
      yield SearchingPoiState(searchingPoi: event.poi);

      try {
        var searchInteractor = Injector
            .of(context)
            .searchInteractor;
        PoiEntity poi =
        await searchInteractor.reverseGeoSearch(event.poi.latLng, Localizations
            .localeOf(context)
            .languageCode);
        poi.name = event.poi.name ?? poi.name;
        poi.address = event.poi.address ?? poi.address;
        poi.remark = event.poi.remark ?? poi.remark;
        poi.latLng = event.poi.latLng ?? poi.latLng;

        yield ShowPoiState(poi: poi);
      } catch (err) {
        logger.e(err);

        PoiEntity poi = PoiEntity();
        poi.name = event.poi.name ?? '未知位置';
        poi.address = event.poi.address ?? '${event.poi.latLng.latitude},${event.poi.latLng.longitude}';
        poi.remark = event.poi.remark;
        poi.latLng = event.poi.latLng;

        yield ShowPoiState(poi: poi);
      }
    }
    /*show poi*/
    else if (event is ShowPoiEvent) {
      yield ShowPoiState(poi: event.poi);
    }
    /*clear selected poi*/
    else if (event is ClearSelectPoiEvent) {
      //check if have search list
      var searchPoiList = currentState.getSearchPoiList();
      if (searchPoiList == null || searchPoiList.isEmpty) {
        yield _getHomeState();
      } else {
        //back to search state
        yield SearchPoiByTextSuccessState();
      }
    }
    //--------------
    // search
    //--------------
    else if (event is SearchTextEvent) {
      yield SearchingPoiByTextState(searchText: event.searchText);

      try {
        var searchInteractor = Injector
            .of(context)
            .searchInteractor;
        var pois = await searchInteractor.searchPoiByMapbox(
            event.searchText, event.center, Localizations
            .localeOf(context)
            .languageCode);

        yield SearchPoiByTextSuccessState(list: pois);
      } catch (e) {
        logger.e(e);
        yield SearchPoiByTextFailState(message: '搜索异常');
      }
    }
    //--------------
    // route
    //--------------
    else if (event is RouteEvent) {
      yield RoutingState(
        fromPoi: event.fromPoi,
        profile: event.profile,
        toPoi: event.toPoi,
        language: event.language,
      );

      try {
        String routeResp =
        await _fetchRoute(event.fromPoi.latLng, event.toPoi.latLng, event.language, profile: event.profile);
        var model = RouteDataModel(
          startLatLng: event.fromPoi.latLng,
          endLatLng: event.toPoi.latLng,
          directionsResponse: routeResp,
          paddingRight: event.paddingRight,
          paddingBottom: event.paddingBottom,
          paddingLeft: event.paddingLeft,
          paddingTop: event.paddingTop,
        );

        yield RouteSuccessState(
          fromPoi: event.fromPoi,
          toPoi: event.toPoi,
          profile: event.profile,
          language: event.language,
          routeDataModel: model,
        );
      } catch (e) {
        logger.e(e);

        yield RouteFailState(
          fromPoi: event.fromPoi,
          toPoi: event.toPoi,
          profile: event.profile,
          language: event.language,
          message: '没有合适的路线',
        );
      }
    } else if (event is ExistRouteEvent) {
      if (currentState.getCurrentPoi() != null) {
        yield ShowPoiState(poi: currentState.getCurrentPoi());
      } else {
        yield _getHomeState();
      }
    }
    //--------------
    // dmap
    //--------------
    else if (event is InitDMapEvent) {
      yield InitDMapState(dMapConfigModel: event.dMapConfigModel);
    }
  }

  ScaffoldMapState _getHomeState() {
    DMapConfigModel dmap = currentState.dMapConfigModel;
    ScaffoldMapState state;
    print('dmapname ${dmap?.dMapName}');
    if (dmap == null) {
      state = InitialScaffoldMapState();
    } else {
      state = InitDMapState(dMapConfigModel: dmap);
    }

    return state;
  }

  ///profile: driving, walking, cycling";
  Future<String> _fetchRoute(LatLng start, LatLng end, String language, {String profile = 'driving'}) async {
    var url =
        'https://api.hyn.space/directions/v5/hyperion/$profile/${start.longitude},${start.latitude};${end
        .longitude},${end
        .latitude}?overview=full&geometries=polyline6&language=$language&steps=true&banner_instructions=true&voice_instructions=true&voice_units=metric&access_token=pk.hyn';
    print(url);
    var httpClient = new HttpClient();
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    if (response.statusCode == HttpStatus.ok) {
      var responseBody = await response.transform(utf8.decoder).join();
      return responseBody;
    }
    throw Exception('fetch error');
  }
}
