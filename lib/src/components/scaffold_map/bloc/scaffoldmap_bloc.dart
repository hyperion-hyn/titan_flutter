import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/data/api/api.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'package:titan/src/data/entity/poi/mapbox_poi.dart';
import 'package:titan/src/data/entity/poi/poi_interface.dart';
import 'package:titan/src/pages/contribution/add_poi/api/position_api.dart';
import 'package:titan/src/data/entity/poi/user_contribution_poi.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc.dart';
import '../../../global.dart';

class ScaffoldMapBloc extends Bloc<ScaffoldMapEvent, ScaffoldMapState> {
  final BuildContext context;

  CancelToken _cancelSearchingRouteToken;

  PositionApi _positionApi = PositionApi();

//  final ScaffoldMapStore store;

  ScaffoldMapBloc(this.context /*, this.store*/);

  @override
  Stream<Transition<ScaffoldMapEvent, ScaffoldMapState>> transformEvents(
      Stream<ScaffoldMapEvent> events, transitionFn) {
//    return super.transformEvents(events, transitionFn);
    return events.switchMap(transitionFn);
  }

  @override
  ScaffoldMapState get initialState => DefaultScaffoldMapState();

  @override
  Stream<ScaffoldMapState> mapEventToState(ScaffoldMapEvent event) async* {
    if (event is DefaultMapEvent) {
//      store.clear();
      yield DefaultScaffoldMapState();
    }
    //--------------
    // poi
    //--------------
    /*search one poi*/
    else if (event is SearchPoiEvent) {
      IPoi poi = event.poi;

      if (poi is UserContributionPoi) {
        yield FocusingPoiState(status: Status.loading, poi: poi);

        try {
          var poiList = await _positionApi.getUserContributionPoiDetail(poi.id);
          var fullInfoPoi = poiList[0];
          yield FocusingPoiState(status: Status.success, poi: fullInfoPoi);
        } catch (e) {
          logger.e(e);

          yield FocusingPoiState(
              status: Status.failed, poi: poi, message: e.message);
        }
      } else if (poi.address == null) {
        //this should be mapbox poi, we need to fill more info about it.
        yield FocusingPoiState(status: Status.loading, poi: poi);

        try {
          var searchInteractor = Injector.of(context).searchInteractor;
          MapBoxPoi searchPoi = await searchInteractor.reverseGeoSearch(
              poi.latLng, Localizations.localeOf(context).languageCode);
          if (poi.name == null) {
            poi.name = searchPoi.name;
          }
          if (poi.address == null) {
            poi.address = searchPoi.address;
          }
          yield FocusingPoiState(status: Status.success, poi: poi);
        } catch (err) {
          logger.e(err);

          MapBoxPoi poi = MapBoxPoi();
          poi.name = event.poi.name ?? S.of(context).unknown_locations;
          poi.address = event.poi.address ??
              '${event.poi.latLng.latitude},${event.poi.latLng.longitude}';
          poi.remark = event.poi.remark;
          poi.latLng = event.poi.latLng;

          yield FocusingPoiState(status: Status.success, poi: poi);
        }
      } else {
        yield FocusingPoiState(status: Status.success, poi: poi);
      }
    }
    /*show poi*/
    else if (event is ShowPoiEvent) {
      yield FocusingPoiState(status: Status.success, poi: event.poi);
    }
    /*clear selected poi*/
//    else if (event is ClearSelectedPoiEvent) {
//      //check if have search list
//      var searchPoiList = state.getSearchPoiList();
//      if (searchPoiList == null || searchPoiList.isEmpty) {
//        yield _getHomeState();
//      } else {
//        //back to search state
//        yield SearchPoiByTextSuccessState();
//      }
//    }
    //--------------
    // search
    //--------------
    else if (event is SearchTextEvent) {
      yield FocusingSearchState(
          status: Status.loading, searchText: event.searchText);

      try {
        if (event.isCategorySearch != true) {
          var searchInteractor = Injector.of(context).searchInteractor;
          var languageCode = Localizations.localeOf(context).languageCode;
          //we search mapbox and user contribution pois
          var poiList = await Future.wait([
            searchInteractor.searchPoiByTitan(
                event.searchText, event.center, languageCode),
            searchInteractor.searchPoiByMapbox(
                event.searchText, event.center, languageCode)
          ]);
          List<IPoi> sum = [];
          sum.addAll(poiList[0]);
          sum.addAll(poiList[1]);
          yield FocusingSearchState(
              status: Status.success, searchText: event.searchText, pois: sum);
        } else {
          //gaode search
          var _api = Api();
          var model;

          if (SettingInheritedModel.of(context, aspect: SettingAspect.area)
                  .areaModel
                  ?.isChinaMainland??true ==
              true) {
            model = await _api.searchByGaode(
                lat: event.center.latitude,
                lon: event.center.longitude,
                type: event.gaodeType);
          } else {
            model = await _api.searchNearByHyn(
                lat: event.center.latitude,
                lon: event.center.longitude,
                type: event.typeOfNearBy,
                language: SettingInheritedModel.of(context,
                        aspect: SettingAspect.language)
                    .languageCode);
          }

          yield FocusingSearchState(
              status: Status.success,
              searchText: event.searchText,
              pois: model.data);
        }
      } catch (e) {
        logger.e(e);
        yield FocusingSearchState(
            status: Status.failed,
            searchText: event.searchText,
            pois: e.message);
      }
    }
    //--------------
    // route
    //--------------
    else if (event is RouteEvent) {
      yield FocusingRouteState(
        status: Status.loading,
        fromPoi: event.fromPoi,
        profile: event.profile,
        toPoi: event.toPoi,
        language: event.language,
      );

      try {
        String routeResp = await _fetchRoute(
            event.fromPoi.latLng, event.toPoi.latLng, event.language,
            profile: event.profile);
        var model = RouteDataModel(
          startLatLng: event.fromPoi.latLng,
          endLatLng: event.toPoi.latLng,
          directionsResponse: routeResp,
          paddingRight: event.paddingRight,
          paddingBottom: event.paddingBottom,
          paddingLeft: event.paddingLeft,
          paddingTop: event.paddingTop,
        );

        yield FocusingRouteState(
          status: Status.success,
          fromPoi: event.fromPoi,
          profile: event.profile,
          toPoi: event.toPoi,
          language: event.language,
          routeDataModel: model,
        );
      } catch (e) {
        logger.e(e);

        yield FocusingRouteState(
            status: Status.failed,
            fromPoi: event.fromPoi,
            profile: event.profile,
            toPoi: event.toPoi,
            language: event.language,
            message: e.message);
      }
    }
//    else if (event is ExistRouteEvent) {
//      if (_cancelSearchingRouteToken != null) {
//        _cancelSearchingRouteToken.cancel();
//        _cancelSearchingRouteToken = null;
//      }
//      if (state.getCurrentPoi() != null) {
//        yield ShowPoiState(poi: state.getCurrentPoi());
//      } else {
//        yield _getHomeState();
//      }
//    }

    //--------------
    // dmap
    //--------------
    else if (event is EnterDMapEvent) {
      yield FocusingDMapState(dMapConfigModel: event.dMapConfigModel);
    }
    //-------------------
    // yield a state
    //-------------------
    else if (event is YieldStateEvent) {
      yield event.state;
    }
  }

//  ScaffoldMapState _getHomeState() {
//    DMapConfigModel dmap = state.dMapConfigModel;
//    ScaffoldMapState mapState;
//    print('dmapname ${dmap?.dMapName}');
//    if (dmap == null) {
//      mapState = DefaultScaffoldMapState();
//    } else {
//      mapState = InitDMapState(dMapConfigModel: dmap);
//    }
//
//    return mapState;
//  }

  ///profile: driving, walking, cycling";
  Future<String> _fetchRoute(LatLng start, LatLng end, String language,
      {String profile = 'driving'}) async {
    _cancelSearchingRouteToken = CancelToken();
    var url =
        'https://api.hyn.space/directions/v5/hyperion/$profile/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=polyline6&language=$language&steps=true&banner_instructions=true&voice_instructions=true&voice_units=metric&access_token=pk.hyn';
//    print("[bloccc] _fetchRoute:$_fetchRoute");
    var responseMap = await HttpCore.instance
        .get(url, cancelToken: _cancelSearchingRouteToken);
    _cancelSearchingRouteToken = null;
    var response = json.encode(responseMap);
    return response;
  }
}
