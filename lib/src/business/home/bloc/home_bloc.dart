import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/inject/injector.dart';
import 'package:titan/src/model/poi.dart';

import './bloc.dart';
import '../searchbar/bloc/bloc.dart' as search;
import '../sheets/bloc/bloc.dart' as sheets;
import '../map/bloc/bloc.dart' as map;

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final BuildContext context;

  HomeBloc({this.context});

  @override
  HomeState get initialState => InitialHomeState();

  sheets.SheetsBloc get sheetBloc => BlocProvider.of<sheets.SheetsBloc>(context);

  search.SearchbarBloc get searchBarBloc => BlocProvider.of<search.SearchbarBloc>(context);

  map.MapBloc get mapBloc => BlocProvider.of<map.MapBloc>(context);

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is ShowPoiEvent) {
      //show bottom sheet of the poi
      sheetBloc.dispatch(sheets.ShowPoiEvent(poi: event.poi));
      //update search bar ui
      searchBarBloc.dispatch(search.ShowPoiEvent(poi: event.poi));
      //add marker on map
      mapBloc.dispatch(map.AddMarkerEvent(poi: event.poi));
    } else if (event is SearchPoiEvent) {
      //add marker on map
      mapBloc.dispatch(map.AddMarkerEvent(poi: event.poi));
      //show bottom sheet loading
      sheetBloc.dispatch(sheets.ShowLoadingEvent());

      //load poi info
      try {
        var searchInteractor = Injector.of(context).searchInteractor;
        PoiEntity poi =
            await searchInteractor.reverseGeoSearch(event.poi.latLng, Localizations.localeOf(context).languageCode);
        //update search bar ui
        searchBarBloc.dispatch(search.ShowPoiEvent(poi: poi));
        //show bottom sheet of the poi
        sheetBloc.dispatch(sheets.ShowPoiEvent(poi: poi));
      } catch (err) {
        print(err);
        //show bottom sheet fail
        sheetBloc.dispatch(sheets.ShowLoadFailEvent(message: '获取数据失败'));
      }
    } else if (event is SearchTextEvent) {
      var searchEvent = search.ShowSearchEvent(isLoading: true, searchText: event.searchText);

      //clear some
      mapBloc.dispatch(map.ClearMarkerEvent());
      mapBloc.dispatch(map.ClearMarkerListEvent());
      sheetBloc.dispatch(sheets.CloseSheetEvent());

      if (event.pois != null && event.pois.length > 0) {
        searchBarBloc.dispatch(searchEvent.copyWith(search.ShowSearchEvent(isLoading: false, pois: event.pois)));
        sheetBloc.dispatch(sheets.ShowSearchItemsEvent(items: event.pois));
        mapBloc.dispatch(map.AddMarkerListEvent(pois: event.pois));
      } else {
        mapBloc.dispatch(map.ClearMarkerListEvent());
        sheetBloc.dispatch(sheets.CloseSheetEvent());

        //loading
        searchBarBloc.dispatch(searchEvent);

        try {
          var searchInteractor = Injector.of(context).searchInteractor;
          var pois = await searchInteractor.searchPoiByMapbox(
              event.searchText, event.center, Localizations.localeOf(context).languageCode);
          if (pois.length > 0) {
            //update searchBar
            searchBarBloc.dispatch(searchEvent.copyWith(search.ShowSearchEvent(isLoading: false, pois: pois)));
            //show bottom list
            sheetBloc.dispatch(sheets.ShowSearchItemsEvent(items: pois));
            //show map search result
            mapBloc.dispatch(map.AddMarkerListEvent(pois: pois));
          } else {
            searchBarBloc.dispatch(searchEvent.copyWith(search.ShowSearchEvent(isLoading: false, failMsg: '无搜索结果')));
          }
        } catch (err) {
          print(err);
          searchBarBloc.dispatch(searchEvent.copyWith(search.ShowSearchEvent(isLoading: false, failMsg: '获取数据失败')));
        }
      }
    } else if (event is ExistSearchEvent) {
      searchBarBloc.dispatch(search.ExistSearchEvent());
      mapBloc.dispatch(map.ClearMarkerEvent());
      mapBloc.dispatch(map.ClearMarkerListEvent());
      sheetBloc.dispatch(sheets.CloseSheetEvent());
    }
  }
}
