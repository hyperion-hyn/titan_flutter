import 'package:flutter_k_chart/entity/k_line_entity.dart';

class MarketSymbolList {
  dynamic baseCurrency;
  KLineEntity hynusdt;
  KLineEntity hyneth;
  KLineEntity hynbtc;

  MarketSymbolList.fromJson(dynamic response) {
    //print('[MarketSymbolList.fromJson] ${(response as List<dynamic>).first}');
    try {
      var json = response[0];
      baseCurrency = json['baseCurrency'];
      Map<String, dynamic> symbols = json['symbols'];
      if (symbols.containsKey('HYN/USDT')) {
        hynusdt = fromSymbolToKLineEntity(symbols['HYN/USDT']);
      }
      if (symbols.containsKey('HYN/ETH')) {
        hyneth = fromSymbolToKLineEntity(symbols['HYN/ETH']);
      }
      if (symbols.containsKey('HYN/BTC')) {
        hynbtc = fromSymbolToKLineEntity(symbols['HYN/BTC']);
      }
    } catch (e) {
      print('[ MarketSymbolList.fromJson] $e');
    }
  }

  KLineEntity fromSymbolToKLineEntity(List itemList) {
    Map<String, dynamic> json = {
      'open': double.parse(itemList[1].toString()),
      'high': double.parse(itemList[2].toString()),
      'low': double.parse(itemList[3].toString()),
      'close': double.parse(itemList[4].toString()),
      'vol': double.parse(itemList[5].toString()),
      'amount': double.parse(itemList[5].toString()),
      'count': 0,
      'id': 0,
    };
    return KLineEntity.fromJson(json);
  }
}
