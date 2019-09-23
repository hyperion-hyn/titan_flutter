import 'package:titan/src/basic/http/http.dart';

class CoinMarketApi {
  Future<Map<String, double>> quotes(List<String> symbols, String convert) async {
    final symbolString = symbols.reduce((value, element) => value + ',' + element);
    var response = await HttpCore.instance.get("https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest",
        params: {"symbol": symbolString, "convert": convert}) as Map;

    var datas = response["data"] as Map;

    var keys = datas.keys as List;

    var priceMap = Map<String, double>();

    for (var key in keys) {
      var price = datas[key]["quote"][convert]["price"];
      priceMap[key] = price;
    }
    return priceMap;
  }
}
