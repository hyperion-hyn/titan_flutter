import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/domain/domain.dart';
import 'package:titan/src/data/entity/poi/mapbox_poi.dart';
import 'package:titan/src/data/entity/poi/poi_interface.dart';
import 'package:titan/src/data/entity/poi/user_contribution_poi.dart';
import 'bloc.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchInteractor searchInteractor;

  SearchBloc({@required this.searchInteractor});

  @override
  SearchState get initialState => InitialSearchState();

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    if (event is AddSearchItemEvent) {
      if (event.item is MapBoxPoi) {
        await searchInteractor.addHistorySearchPoi(event.item);
      } else if (event.item is UserContributionPoi) {
        await searchInteractor.addHistorySearchPoiByTitan(event.item);
      } else {
        await searchInteractor.addHistorySearchText(event.item.toString());
      }
    } else if (event is FetchSearchItemsEvent) {
      if (event.isHistory) {
        //only load 20 items
        List<dynamic> items = await searchInteractor.searchHistoryList();
        yield SearchLoadedState(isHistory: true, items: items, currentSearchText: '');
      } else {
        //not support multi page currently
        try {
          var items = await _searchPoi(event);
          yield SearchLoadedState(isHistory: false, currentSearchText: event.searchText, items: items);
        } catch (err) {
          print(err.toString());
        }
      }
    } else if (event is ClearSearchHisotoryEvent) {
      await searchInteractor.deleteAllHistory();
      yield SearchLoadedState(isHistory: true, items: [], currentSearchText: '');
    }
  }

  Future<List<IPoi>> _searchPoiByMapbox(FetchSearchItemsEvent event) async {
    var items = await searchInteractor.searchPoiByMapbox(event.searchText, event.center, event.language);
    return items;
  }

  Future<List<IPoi>> _searchPoiByTitan(FetchSearchItemsEvent event) async {
    var items = await searchInteractor.searchPoiByTitan(event.searchText, event.center, event.language);
    return items;
  }

  Future<List<IPoi>> _searchPoi(FetchSearchItemsEvent event) async {
    return Future.wait([_searchPoiByTitan(event), _searchPoiByMapbox(event)]).then((List<List<IPoi>> list) {
      List<IPoi> sum = [];
      sum.addAll(list[0]);
      sum.addAll(list[1]);
      print('[search_bloc] --> sum:$sum, sumCount:${sum.length}');
      return sum;
    });
  }
}
