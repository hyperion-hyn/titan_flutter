import 'package:meta/meta.dart';
import 'package:titan/src/data/api/api.dart';
import 'package:titan/src/data/db/heco_txn_dao.dart';
import 'package:titan/src/data/db/search_history_dao.dart';
import 'package:titan/src/data/db/transfer_history_dao.dart';
import '../entity/update.dart';

class Repository {
  Api api;
  SearchHistoryDao searchHistoryDao;
  TransferHistoryDao transferHistoryDao;
  TxnInfoDao txInfoDao;

  Repository(
      {@required Api api,
      @required SearchHistoryDao searchHistoryDao,
      @required TransferHistoryDao transferHistoryDao,
      @required TxnInfoDao txnInfoDao})
      : api = api,
        searchHistoryDao = searchHistoryDao,
        transferHistoryDao = transferHistoryDao,
        txInfoDao = txnInfoDao;

  Future<UpdateEntity> checkNewVersion(String channel, String lang, String platform) {
    return api.update(channel, lang, platform);
  }
}
