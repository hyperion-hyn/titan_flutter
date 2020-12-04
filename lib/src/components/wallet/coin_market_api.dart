import 'package:dio/dio.dart';
import 'package:titan/config.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_http.dart';

import 'vo/symbol_quote_entity.dart';
import 'vo/symbol_quote_vo.dart';

class CoinMarketApi {
  Future<List<SymbolQuoteVo>> quotes(int timestamp) async {
    var response = await AtlasHttpCore.instance.postEntity('v1/wallet/quotes',
        EntityFactory<SymbolQuoteEntity>(
              (json) => SymbolQuoteEntity.fromJson(json),
        ),
        params: {
          "ts": timestamp,
        },
        options: RequestOptions(contentType: "application/json"));

    List<SymbolQuoteVo> list = [];
    var btcVo1 = SymbolQuoteVo(symbol: "BTC", quote: "CNY", price: response.btcCnyPrice, percentChange24h: response.btcPercentChangeCny24h);
    list.add(btcVo1);
    var btcVo2 = SymbolQuoteVo(symbol: "BTC", quote: "USD", price: response.btcUsdPrice, percentChange24h: response.btcPercentChangeUsd24h);
    list.add(btcVo2);

    var ethVo1 = SymbolQuoteVo(symbol: "ETH", quote: "CNY", price: response.ethCnyPrice, percentChange24h: response.ethPercentChangeCny24h);
    list.add(ethVo1);
    var ethVo2 = SymbolQuoteVo(symbol: "ETH", quote: "USD", price: response.ethUsdPrice, percentChange24h: response.ethPercentChangeUsd24h);
    list.add(ethVo2);

    var hynVo1 = SymbolQuoteVo(symbol: "HYN", quote: "CNY", price: response.hynCnyPrice, percentChange24h: response.hynPercentChangeCny24h);
    list.add(hynVo1);
    var hynVo2 = SymbolQuoteVo(symbol: "HYN", quote: "USD", price: response.hynUsdPrice, percentChange24h: response.hynPercentChangeUsd24h);
    list.add(hynVo2);

    var usdtVo1 = SymbolQuoteVo(symbol: "USDT", quote: "CNY", price: response.usdtCnyPrice, percentChange24h: response.usdtPercentChangeCny24h);
    list.add(usdtVo1);
    var usdtVo2 = SymbolQuoteVo(symbol: "USDT", quote: "USD", price: response.usdtUsdPrice, percentChange24h: response.usdtPercentChangeUsd24h);
    list.add(usdtVo2);

    var rpVo1 = SymbolQuoteVo(symbol: "RP", quote: "CNY", price: response.rpCnyPrice, percentChange24h: response.rpPercentChangeCny24h);
    list.add(rpVo1);
    var rpVo2 = SymbolQuoteVo(symbol: "RP", quote: "USD", price: response.rpUsdPrice, percentChange24h: response.rpPercentChangeUsd24h);
    list.add(rpVo2);

    return list;
  }
}
