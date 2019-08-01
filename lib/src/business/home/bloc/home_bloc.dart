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

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is ShowPoiEvent) {
      //update search bar ui
      BlocProvider.of<search.SearchbarBloc>(context).dispatch(search.ShowPoiEvent(poi: event.poi));
      //add marker on map
      BlocProvider.of<map.MapBloc>(context).dispatch(map.AddMarkerEvent(coordinate: event.poi.latLng));
      //show bottom sheet of the poi
      BlocProvider.of<sheets.SheetsBloc>(context).dispatch(sheets.ShowPoiEvent(poi: event.poi));
    } else if (event is SearchPoiEvent) {
      //add marker on map
      BlocProvider.of<map.MapBloc>(context).dispatch(map.AddMarkerEvent(coordinate: event.latLng));
      //show bottom sheet loading
      BlocProvider.of<sheets.SheetsBloc>(context).dispatch(sheets.ShowLoadingEvent());

      //load poi info
      try {
        var searchInteractor = Injector.of(context).searchInteractor;
        PoiEntity poi =
            await searchInteractor.reverseGeoSearch(event.latLng, Localizations.localeOf(context).languageCode);
        //update search bar ui
        BlocProvider.of<search.SearchbarBloc>(context).dispatch(search.ShowPoiEvent(poi: poi));
        //show bottom sheet of the poi
        BlocProvider.of<sheets.SheetsBloc>(context).dispatch(sheets.ShowPoiEvent(poi: poi));
      } catch (err) {
        print(err);
        //show bottom sheet fail
        BlocProvider.of<sheets.SheetsBloc>(context).dispatch(sheets.ShowLoadFailEvent(message: '获取数据失败'));
      }
    } else if (event is SearchTextEvent) {
      var searchEvent = search.ShowSearchEvent(isLoading: true, searchText: event.searchText);

      if (event.pois != null && event.pois.length > 0) {
        BlocProvider.of<search.SearchbarBloc>(context)
            .dispatch(searchEvent.copyWith(search.ShowSearchEvent(isLoading: false, pois: event.pois)));
        BlocProvider.of<sheets.SheetsBloc>(context).dispatch(sheets.ShowSearchItemsEvent(items: event.pois));
        BlocProvider.of<map.MapBloc>(context).dispatch(map.AddMarkerListEvent(pois: event.pois));
      } else {
        BlocProvider.of<map.MapBloc>(context).dispatch(map.ClearMarkerListEvent());
        BlocProvider.of<sheets.SheetsBloc>(context).dispatch(sheets.CloseSheetEvent());

        //loading
        BlocProvider.of<search.SearchbarBloc>(context).dispatch(searchEvent);

        try {
          var searchInteractor = Injector.of(context).searchInteractor;
          var pois = await searchInteractor.searchPoiByMapbox(
              event.searchText, event.center, Localizations.localeOf(context).languageCode);
          if (pois.length > 0) {
            //update searchBar
            BlocProvider.of<search.SearchbarBloc>(context)
                .dispatch(searchEvent.copyWith(search.ShowSearchEvent(isLoading: false, pois: pois)));
            //show bottom list
            BlocProvider.of<sheets.SheetsBloc>(context).dispatch(sheets.ShowSearchItemsEvent(items: pois));
            //show map search result
            BlocProvider.of<map.MapBloc>(context).dispatch(map.AddMarkerListEvent(pois: pois));
          } else {
            BlocProvider.of<search.SearchbarBloc>(context)
                .dispatch(searchEvent.copyWith(search.ShowSearchEvent(isLoading: false, failMsg: '无搜索结果')));
          }
        } catch (err) {
          print(err);
          BlocProvider.of<search.SearchbarBloc>(context)
              .dispatch(searchEvent.copyWith(search.ShowSearchEvent(isLoading: false, failMsg: '获取数据失败')));
        }
      }
    } else if (event is ExistSearchEvent) {
      BlocProvider.of<search.SearchbarBloc>(context).dispatch(search.ExistSearchEvent());
      BlocProvider.of<map.MapBloc>(context).dispatch(map.ClearMarkerEvent());
      BlocProvider.of<map.MapBloc>(context).dispatch(map.ClearMarkerListEvent());
      BlocProvider.of<sheets.SheetsBloc>(context).dispatch(sheets.CloseSheetEvent());
    }
  }
}
