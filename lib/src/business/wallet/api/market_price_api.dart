import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/business/wallet/model/hyn_market_price_response.dart';

class MarketPriceApi {
  ///
  Future<HynMarketPriceResponse> getHynMarketPriceResponse() async {
    return await HttpCore.instance.getEntity("api/v1/market/prices", EntityFactory<HynMarketPriceResponse>((json) {
      return HynMarketPriceResponse.fromJson(json);
    }));
  }
}
