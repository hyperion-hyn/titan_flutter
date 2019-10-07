import 'package:dio/dio.dart';
import 'package:titan/src/basic/http/http.dart';

class CoinMarketApi {
  Future<Map<String, double>> quotes(List<String> symbols, String convert) async {
    final symbolString = symbols.reduce((value, element) => value + ',' + element);
    var response = await HttpCore.instance.get("https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest",
        params: {"symbol": symbolString, "convert": convert},options: RequestOptions(
          headers: {
            "X-CMC_PRO_API_KEY":"fb9255df-cc33-4cc2-9f6a-7e807741dfef",
            "Accept":"application/json"
          }
        )) as Map;

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
