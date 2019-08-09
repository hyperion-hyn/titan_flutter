import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/inject/injector.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/model/poi_interface.dart';

import './bloc.dart';
import '../searchbar/bloc/bloc.dart' as search;
import '../sheets/bloc/bloc.dart' as sheets;
import '../map/bloc/bloc.dart' as map;

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  BuildContext context;

  HomeBloc({this.context});

  @override
  HomeState get initialState => InitialHomeState();

  sheets.SheetsBloc sheetBloc;

  search.SearchbarBloc searchBarBloc;

  map.MapBloc mapBloc;

  //search data
  List<IPoi> searchList;
  String searchText;

  //showing poi
  IPoi selectedPoi;


  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is ShowPoiEvent) {
      //show bottom sheet of the poi
      sheetBloc.dispatch(sheets.ShowPoiEvent(poi: event.poi));
      //update search bar ui
      searchBarBloc.dispatch(search.ShowPoiEvent(poi: event.poi, prvSearchText: searchText));
      //add marker on map
      mapBloc.dispatch(map.AddMarkerEvent(poi: event.poi));
      selectedPoi = event.poi;
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
        poi.name = event.poi.name??poi.name;
        //update search bar ui
        searchBarBloc.dispatch(search.ShowPoiEvent(poi: poi));
        //show bottom sheet of the poi
        sheetBloc.dispatch(sheets.ShowPoiEvent(poi: poi));
        selectedPoi = poi;
      } catch (err) {
        print(err);
        //show bottom sheet fail
        sheetBloc.dispatch(sheets.ShowLoadFailEvent(message: '获取数据失败'));
      }
    } else if (event is SearchTextEvent) {
      var searchEvent = search.ShowSearchEvent(isLoading: true, searchText: event.searchText);

      //clear some
      selectedPoi = null;
      mapBloc.dispatch(map.ClearMarkerEvent());
      mapBloc.dispatch(map.ClearMarkerListEvent());
      sheetBloc.dispatch(sheets.CloseSheetEvent());

//      if (event.pois != null && event.pois.length > 0) {
      if (searchText != null && searchList != null && searchText == event.searchText) {
        //back to search result
        searchBarBloc.dispatch(searchEvent.copyWith(search.ShowSearchEvent(isLoading: false, pois: searchList)));
        sheetBloc.dispatch(sheets.ShowSearchItemsEvent(items: searchList));
        mapBloc.dispatch(map.AddMarkerListEvent(pois: searchList));
      } else {
        searchText = event.searchText;

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

            searchList = pois;
          } else {
            searchBarBloc.dispatch(searchEvent.copyWith(search.ShowSearchEvent(isLoading: false, failMsg: '无搜索结果')));
          }
        } catch (err) {
          print(err);
          searchBarBloc.dispatch(searchEvent.copyWith(search.ShowSearchEvent(isLoading: false, failMsg: '获取数据失败')));
        }
      }
    } else if (event is ExistSearchEvent) {
      searchList = null;
      searchText = null;
      selectedPoi =  null;

      searchBarBloc.dispatch(search.ExistSearchEvent());
      mapBloc.dispatch(map.ClearMarkerEvent());
      mapBloc.dispatch(map.ClearMarkerListEvent());
      sheetBloc.dispatch(sheets.CloseSheetEvent());
    } /*else if(event is RouteEvent) {
      searchBarBloc.dispatch(search.HideSearchBarEvent());
      sheetBloc.dispatch(sheets.CloseSheetEvent());
      mapBloc.dispatch(map.ClearMarkerEvent());
      mapBloc.dispatch(map.ClearMarkerListEvent());

      eventBus.fire(RouteClickEvent());
    }*/
  }
}
