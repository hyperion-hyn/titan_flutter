import 'package:meta/meta.dart';
import 'package:titan/src/model/update.dart';
import 'package:titan/src/data/api/api.dart';
import 'package:titan/src/data/db/search_history_dao.dart';

class Repository {
  Api api;
  SearchHistoryDao searchHistoryDao;

  Repository({@required Api api, @required SearchHistoryDao searchHistoryDao})
      : api = api,
        searchHistoryDao = searchHistoryDao;

  Future<UpdateEntity> checkNewVersion(String channel, String lang) {
    return api.update(channel, lang);
  }
}
