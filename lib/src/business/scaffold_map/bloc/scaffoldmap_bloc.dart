import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:titan/src/business/scaffold_map/dapp/dapp_define.dart';
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
  Stream<ScaffoldMapState> transform(
      Stream<ScaffoldMapEvent> events, Stream<ScaffoldMapState> Function(ScaffoldMapEvent event) next) {
    return super.transform(events, next);
  }

  @override
  Stream<ScaffoldMapState> mapEventToState(ScaffoldMapEvent event) async* {
    if (event is InitMapEvent) {
      ScaffoldMapStore.shared.clearAll();
      yield InitialScaffoldMapState();
    }
    /*search one poi*/
    else if (event is SearchPoiEvent) {
      yield SearchingPoiState(searchingPoi: event.poi);

      try {
        var searchInteractor = Injector.of(context).searchInteractor;
        PoiEntity poi =
            await searchInteractor.reverseGeoSearch(event.poi.latLng, Localizations.localeOf(context).languageCode);
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
        yield getDappHomeState();
      } else {
        //back to search state
        yield SearchPoiByTextSuccessState();
      }
    }
    /* search text */
    else if (event is SearchTextEvent) {
      yield SearchingPoiByTextState(searchText: event.searchText);

      try {
        var searchInteractor = Injector.of(context).searchInteractor;
        var pois = await searchInteractor.searchPoiByMapbox(
            event.searchText, event.center, Localizations.localeOf(context).languageCode);

        yield SearchPoiByTextSuccessState(list: pois);
      } catch (e) {
        logger.e(e);
        yield SearchPoiByTextFailState(message: '搜索异常');
      }
    }
  }

  ScaffoldMapState getDappHomeState() {
    DAppDefine dapp = currentState.getCurrentDapp();
    ScaffoldMapState state;
    switch (dapp) {
      case DAppDefine.NIGHT_LIFE:
        state = NightLifeState();
        break;
      case DAppDefine.POLICE:
        state = PoliceState();
        break;
      default:
        state = InitialScaffoldMapState();
        break;
    }

    return state;
  }
}
