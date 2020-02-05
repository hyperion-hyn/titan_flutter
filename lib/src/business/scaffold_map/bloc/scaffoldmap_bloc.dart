import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/business/position/api/position_api.dart';
import 'package:titan/src/business/position/model/confirm_poi_item.dart';
import 'package:titan/src/business/scaffold_map/dmap/dmap.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/data/api/api.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/model/poi_interface.dart';

import './bloc.dart';
import '../../../global.dart';

class ScaffoldMapBloc extends Bloc<ScaffoldMapEvent, ScaffoldMapState> {
  final BuildContext context;

  CancelToken _cancelToken;

  PositionApi _positionApi = PositionApi();

  ScaffoldMapBloc(this.context);

  @override
  ScaffoldMapState get initialState => InitialScaffoldMapState();

  @override
  Stream<ScaffoldMapState> mapEventToState(ScaffoldMapEvent event) async* {
    print("currentEvent:$event");

    if (event is InitMapEvent) {
      ScaffoldMapStore.shared.clearAll();
      yield InitialScaffoldMapState();
    }
    //--------------
    // poi
    //--------------
    /*search one poi*/
    else if (event is SearchPoiEvent) {
      IPoi poi = event.poi;

      if (poi is ConfirmPoiItem) {
        yield SearchingPoiState(searchingPoi: poi);

        var _confirmDataList = await _positionApi.mapGetConfirmData(poi.id);
        var fullInfomationPoi = _confirmDataList[0];
        yield ShowPoiState(poi: fullInfomationPoi);
      } else if (poi.address == null) {
        yield SearchingPoiState(searchingPoi: poi);

        try {
          var searchInteractor = Injector.of(context).searchInteractor;
          PoiEntity searchPoi =
              await searchInteractor.reverseGeoSearch(poi.latLng, Localizations.localeOf(context).languageCode);
          if (poi.name == null) {
            poi.name = searchPoi.name;
          }
          if (poi.address == null) {
            poi.address = searchPoi.address;
          }
          yield ShowPoiState(poi: poi);
        } catch (err) {
          logger.e(err);

          PoiEntity poi = PoiEntity();
          poi.name = event.poi.name ?? S.of(globalContext).unknown_locations;
          poi.address = event.poi.address ?? '${event.poi.latLng.latitude},${event.poi.latLng.longitude}';
          poi.remark = event.poi.remark;
          poi.latLng = event.poi.latLng;

          yield ShowPoiState(poi: poi);
        }
      } else {
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
      var searchPoiList = state.getSearchPoiList();
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
        if (event.isGaodeSearch != true) {
          var searchInteractor = Injector.of(context).searchInteractor;
          var languageCode = Localizations.localeOf(context).languageCode;
          var poiList = await Future.wait([
            searchInteractor.searchPoiByTitan(event.searchText, event.center, languageCode),
            searchInteractor.searchPoiByMapbox(event.searchText, event.center, languageCode)
          ]);
          List<IPoi> sum = [];
          sum.addAll(poiList[0]);
          sum.addAll(poiList[1]);
          yield SearchPoiByTextSuccessState(list: sum);
        } else {
          //gaode search
          var _api = Api();
          var gaodeModel;

          if (SettingInheritedModel.of(context, aspect: SettingAspect.area).areaModel?.isChinaMainland == true) {
            gaodeModel =
                await _api.searchByGaode(lat: event.center.latitude, lon: event.center.longitude, type: event.type);
          } else {
            gaodeModel = await _api.searchNearByHyn(
                lat: event.center.latitude,
                lon: event.center.longitude,
                type: event.stringType,
                language: SettingInheritedModel.of(context, aspect: SettingAspect.language).languageCode);
          }

          yield SearchPoiByTextSuccessState(list: gaodeModel.data);
        }
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
      if (_cancelToken != null) {
        _cancelToken.cancel();
      }
      if (state.getCurrentPoi() != null) {
        yield ShowPoiState(poi: state.getCurrentPoi());
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
    DMapConfigModel dmap = state.dMapConfigModel;
    ScaffoldMapState mapState;
    print('dmapname ${dmap?.dMapName}');
    if (dmap == null) {
      mapState = InitialScaffoldMapState();
    } else {
      mapState = InitDMapState(dMapConfigModel: dmap);
    }

    return mapState;
  }

  ///profile: driving, walking, cycling";
  Future<String> _fetchRoute(LatLng start, LatLng end, String language, {String profile = 'driving'}) async {
    _cancelToken = CancelToken();
    var url =
        'https://api.hyn.space/directions/v5/hyperion/$profile/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=polyline6&language=$language&steps=true&banner_instructions=true&voice_instructions=true&voice_units=metric&access_token=pk.hyn';
    print(url);
    var responseMap = await HttpCore.instance.get(url, cancelToken: _cancelToken);
    _cancelToken = null;
    var response = json.encode(responseMap);
    return response;
  }
}
