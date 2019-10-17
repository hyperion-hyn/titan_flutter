import 'package:meta/meta.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/model/dianping_poi.dart';
import 'package:titan/src/model/update.dart';
import 'package:titan/src/data/api/api.dart';
import 'package:titan/src/data/db/search_history_dao.dart';

class Repository {
  Api api;
  SearchHistoryDao searchHistoryDao;

  Repository({@required Api api, @required SearchHistoryDao searchHistoryDao})
      : api = api,
        searchHistoryDao = searchHistoryDao;

  Future<UpdateEntity> checkNewVersion(String channel, String lang, String platform) {
    return api.update(channel, lang, platform);
  }

  Future<List<DianPingPoi>> requestDianping(double lat, double lon) async {
    List<DianPingPoi> pois = [];
    var data = await api.requestDianping(lat, lon);
    try {
      List list = data['data']['moduleInfoList'][0]['moduleData']['data']['guessYouVoList'];
      for (int i = 0; i < list.length; i++) {
        var item = list[i];
        var poi = DianPingPoi();
        poi.address = ''; //无经纬度
        poi.name = item['shopName'];
        poi.shopName = item['shopName'];
        poi.dealGroupTitle = item['dealGroupTitle'];
        poi.dealgroupPrice = item['dealgroupPrice'];
        poi.marketPrice = item['marketPrice'];
        poi.defaultPic = item['defaultPic'];
        poi.salesdesc = item['salesdesc'];
        poi.schema = item['schema'];
        pois.add(poi);
      }
    } catch (e) {
      logger.e(e);
    }
    return pois;
  }
}
