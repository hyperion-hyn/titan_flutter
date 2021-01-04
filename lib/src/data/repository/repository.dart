import 'package:meta/meta.dart';
import 'package:titan/src/data/api/api.dart';
import 'package:titan/src/data/db/search_history_dao.dart';
import 'package:titan/src/data/db/transfer_history_dao.dart';
import '../entity/update.dart';

class Repository {
  Api api;
  SearchHistoryDao searchHistoryDao;
  TransferHistoryDao transferHistoryDao;

  Repository(
      {@required Api api,
      @required SearchHistoryDao searchHistoryDao,
      @required TransferHistoryDao transferHistoryDao})
      : api = api,
        searchHistoryDao = searchHistoryDao,
        transferHistoryDao = transferHistoryDao;

  Future<UpdateEntity> checkNewVersion(
      String channel, String lang, String platform) {
    return api.update(channel, lang, platform);
  }
}
