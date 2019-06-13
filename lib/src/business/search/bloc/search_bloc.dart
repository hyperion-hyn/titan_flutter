import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/domain/domain.dart';
import 'package:titan/src/model/search_poi.dart';
import 'bloc.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchInteractor searchInteractor;

  SearchBloc({@required this.searchInteractor});

  @override
  SearchState get initialState => InitialSearchState();

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    if (event is AddSearchItemEvent) {
      if (event.item is SearchPoiEntity) {
        await searchInteractor.addSearchPoi(event.item);
      } else {
        await searchInteractor.addSearchText(event.item.toString());
      }
      yield currentState; //nothing to do
    } else if (event is FetchSearchItemsEvent) {
      if (event.isHistory) {
        //only load 20 items
        List<dynamic> items = await searchInteractor.searchHistoryList();
        yield SearchLoadedState(isHistory: true, items: items, currentSearchText: '');
      } else {
        //not support multi page currently
        try {
          var items = await searchInteractor.searchPoiByMapbox(event.searchText, event.center, event.language);
          yield SearchLoadedState(isHistory: false, currentSearchText: event.searchText, items: items);
        } catch (err) {
          print(err.toString());
          yield currentState; //nothing to do
        }
      }
    } else if(event is ClearSearchHisotoryEvent) {
      await searchInteractor.deleteAllHistory();
      yield SearchLoadedState(isHistory: true, items: [], currentSearchText: '');
    }
  }
}
