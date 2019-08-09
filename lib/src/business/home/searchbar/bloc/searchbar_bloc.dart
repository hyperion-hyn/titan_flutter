import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/business/home/bloc/bloc.dart' as home;
import './bloc.dart';

class SearchbarBloc extends Bloc<SearchbarEvent, SearchbarState> {
  BuildContext context;

  home.HomeBloc homeBloc;

  SearchbarBloc({this.context});

  @override
  SearchbarState get initialState => InitialSearchbarState();

  @override
  Stream<SearchbarState> mapEventToState(SearchbarEvent event) async* {
    if (event is ShowSearchEvent) {
      yield SearchTextState(
        pois: event.pois,
        isLoading: event.isLoading,
        searchText: event.searchText,
        failMsg: event.failMsg,
      );
    } else if (event is ShowPoiEvent) {
//      if (currentState is SearchTextState) {
//        var cs = (currentState as SearchTextState);
//        yield SearchPoiState(poi: event.poi, prvSearchPois: cs.pois, prvSearchText: cs.searchText);
//      } else if (currentState is SearchPoiState) {
//        yield (currentState as SearchPoiState).copyWith(SearchPoiState(poi: event.poi));
//      } else {
//        yield SearchPoiState(poi: event.poi);
//      }

      yield SearchPoiState(poi: event.poi, prvSearchText: event.prvSearchText);
    } else if (event is ExistSearchEvent) {
      yield InitialSearchbarState();
    } else if(event is HideSearchBarEvent) {
      yield HideSearchBarState();
    }
  }
}
