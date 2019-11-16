import 'package:dio/dio.dart';
import 'package:titan/config.dart';
import 'package:titan/src/basic/http/http.dart';

class CoinMarketApi {
  Future<Map<String, double>> quotes(List<String> symbols, String convert) async {
    final symbolString = symbols.reduce((value, element) => value + ',' + element);
    var response = await HttpCore.instance.get('${Config.COINMARKETCAP_API_URL}/v1/cryptocurrency/quotes/latest',
        params: {"symbol": symbolString, "convert": convert},
        options: RequestOptions(
            headers: {"X-CMC_PRO_API_KEY": Config.COINMARKETCAP_PRVKEY, "Accept": "application/json"})) as Map;

    var datas = response["data"] as Map;

    var keys = datas.keys;

    var priceMap = Map<String, double>();

    for (var key in keys) {
      var price = datas[key]["quote"][convert]["price"];
      priceMap[key] = price;
    }
    return priceMap;
  }
}
