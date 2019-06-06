import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:titan/src/model/history_search.dart';
import 'package:titan/src/resource/db/search_history_dao.dart';

class SearchHistoryBloc extends BlocBase {
  SearchHistoryDao dao;

  SearchHistoryBloc(this.dao);

  Future<HistorySearchEntity> addSearchHistory(HistorySearchEntity entity) {
    return dao.insert(entity);
  }

  Future<List<HistorySearchEntity>> searchHistoryList() {
    return dao.getList();
  }
}
