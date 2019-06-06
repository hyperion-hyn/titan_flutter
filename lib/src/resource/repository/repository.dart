import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/model/update.dart';
import 'package:titan/src/resource/api/api.dart';
import 'package:titan/src/resource/db/search_history_dao.dart';

class Repository extends Disposable {
  Api _api;
  SearchHistoryDao _searchHistoryDao;

  Repository({@required Api api, @required SearchHistoryDao searchHistoryDao})
      : _api = api,
        _searchHistoryDao = searchHistoryDao;

  Future<UpdateEntity> checkNewVersion(String channel, String lang) {
    return _api.update(channel, lang);
  }

  @override
  void dispose() {}
}
