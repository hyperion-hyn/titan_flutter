import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:titan/config.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_http.dart';

import 'entity/tokens_price_entity.dart';
import 'vo/token_price_view_vo.dart';

class CoinMarketApi {
  /// 历史行情数据
  Future<List<TokenPriceViewVo>> quotes(int timestamp) async {
    var response = await AtlasHttpCore.instance.postEntity(
        'v1/wallet/quotes',
        EntityFactory<TokensPriceEntity>(
          (json) => TokensPriceEntity.fromJson(json),
        ),
        params: {
          "ts": timestamp,
        },
        options: RequestOptions(contentType: "application/json"));

    List<TokenPriceViewVo> list = [];
    var cnyLegalSign = SupportedLegal.of('CNY');
    var usdLegalSign = SupportedLegal.of('USD');
    var btcVo1 = TokenPriceViewVo(
        symbol: "BTC",
        legal: cnyLegalSign,
        price: response.btcCnyPrice,
        percentChange24h: response.btcPercentChangeCny24h);
    list.add(btcVo1);
    var btcVo2 = TokenPriceViewVo(
        symbol: "BTC",
        legal: usdLegalSign,
        price: response.btcUsdPrice,
        percentChange24h: response.btcPercentChangeUsd24h);
    list.add(btcVo2);

    var ethVo1 = TokenPriceViewVo(
        symbol: "ETH",
        legal: cnyLegalSign,
        price: response.ethCnyPrice,
        percentChange24h: response.ethPercentChangeCny24h);
    list.add(ethVo1);
    var ethVo2 = TokenPriceViewVo(
        symbol: "ETH",
        legal: usdLegalSign,
        price: response.ethUsdPrice,
        percentChange24h: response.ethPercentChangeUsd24h);
    list.add(ethVo2);

    var hynVo1 = TokenPriceViewVo(
        symbol: "HYN",
        legal: cnyLegalSign,
        price: response.hynCnyPrice,
        percentChange24h: response.hynPercentChangeCny24h);
    list.add(hynVo1);
    var hynVo2 = TokenPriceViewVo(
        symbol: "HYN",
        legal: usdLegalSign,
        price: response.hynUsdPrice,
        percentChange24h: response.hynPercentChangeUsd24h);
    list.add(hynVo2);

    var usdtVo1 = TokenPriceViewVo(
        symbol: "USDT",
        legal: cnyLegalSign,
        price: response.usdtCnyPrice,
        percentChange24h: response.usdtPercentChangeCny24h);
    list.add(usdtVo1);
    var usdtVo2 = TokenPriceViewVo(
        symbol: "USDT",
        legal: usdLegalSign,
        price: response.usdtUsdPrice,
        percentChange24h: response.usdtPercentChangeUsd24h);
    list.add(usdtVo2);

    var rpVo1 = TokenPriceViewVo(
        symbol: "RP",
        legal: cnyLegalSign,
        price: response.rpCnyPrice,
        percentChange24h: response.rpPercentChangeCny24h);
    list.add(rpVo1);
    var rpVo2 = TokenPriceViewVo(
        symbol: "RP",
        legal: usdLegalSign,
        price: response.rpUsdPrice,
        percentChange24h: response.rpPercentChangeUsd24h);
    list.add(rpVo2);

    return list;
  }

  /// 最新行情数据
  Future<List<TokenPriceViewVo>> quotesLatest(List<String> quoteConverts) async {
    var response = await HttpCore.instance.get('api/v1/market/prices/latest',
        options: RequestOptions(
            headers: {"X-CMC_PRO_API_KEY": Config.COINMARKETCAP_PRVKEY, "Accept": "application/json"})) as Map;

    var status = response['state'];
    if (status['error_code'] == 0) {
      List<TokenPriceViewVo> list = [];
      var datas = response["data"] as Map;
      var keys = datas.keys;
      for (var key in keys) {
        for (var convert in quoteConverts) {
          var legalSign = SupportedLegal.of(convert);
          if (legalSign != null) {
            var price = datas[key]["quote"][convert]["price"];
            var percentChange24h = datas[key]["quote"][convert]["percent_change_24h"];
            var vo = TokenPriceViewVo(
                symbol: key,
                legal: legalSign,
                price: price,
                percentChange24h: Decimal.tryParse(percentChange24h.toString()).toDouble());
            list.add(vo);
          }
        }
      }
      return list;
    }

    throw HttpResponseCodeNotSuccess(status['error_code'], status['error_message']);
  }
}
