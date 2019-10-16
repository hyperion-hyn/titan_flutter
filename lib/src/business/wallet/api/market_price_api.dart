import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/business/wallet/model/hyn_market_price_info.dart';

class MarketPriceApi {
  ///
  Future<List<HynMarketPriceInfo>> getHynMarketPriceInfoList() async {
    return await HttpCore.instance.getEntity("api/v1/market/prices", EntityFactory<List<HynMarketPriceInfo>>((json) {
      return (json as List).map((contractJson) {
        return HynMarketPriceInfo.fromJson(contractJson);
      }).toList();
    }));
  }
}
