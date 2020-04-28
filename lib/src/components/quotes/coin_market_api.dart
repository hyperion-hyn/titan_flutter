import 'package:dio/dio.dart';
import 'package:titan/config.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/basic/http/http_exception.dart';

import 'vo/symbol_quote_vo.dart';

class CoinMarketApi {
  Future<List<SymbolQuoteVo>> quotes(List<String> symbols, List<String> quoteConverts) async {
    final symbolString = symbols.reduce((value, element) => value + ',' + element);
    final convert = quoteConverts.reduce((value, element) => value + ',' + element);
    var response = await HttpCore.instance.get('${Config.COINMARKETCAP_API_URL}/v1/cryptocurrency/quotes/latest',
        params: {"symbol": symbolString, "convert": convert},
        options: RequestOptions(
            headers: {"X-CMC_PRO_API_KEY": Config.COINMARKETCAP_PRVKEY, "Accept": "application/json"})) as Map;

    var status = response['status'];
    if (status['error_code'] == 0) {
      List<SymbolQuoteVo> list = [];
      var datas = response["data"] as Map;
      var keys = datas.keys;
      for (var key in keys) {
        for (var convert in quoteConverts) {
          var price = datas[key]["quote"][convert]["price"];
          var percentChange24h = datas[key]["quote"][convert]["percent_change_24h"];
          var vo = SymbolQuoteVo(symbol: key, quote: convert, price: price, percentChange24h: percentChange24h);
          list.add(vo);
        }
      }
      return list;
    }

    throw HttpResponseCodeNotSuccess(status['error_code'], status['error_message']);
  }
}
