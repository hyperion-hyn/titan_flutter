import 'package:k_chart/flutter_k_chart.dart';
import 'package:titan/src/pages/market/entity/market_item_entity.dart';

class MarketSymbolList {
  dynamic baseCurrency;
  KLineEntity hynusdt;
  KLineEntity hyneth;
  KLineEntity hynbtc;
  KLineEntity rphyn;

  @deprecated
  MarketSymbolList.fromJson(dynamic response) {
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
      if (symbols.containsKey('RP/HYN')) {
        rphyn = fromSymbolToKLineEntity(symbols['RP/HYN']);
      }
    } catch (e) {
      print('[ MarketSymbolList.fromJson] $e');
    }
  }

  static List<MarketItemEntity> fromJsonToMarketItemList(dynamic response) {
    List<MarketItemEntity> marketItemList = List();
    try {
      var json = response[0];
      Map<String, dynamic> symbols = json['symbols'];

      symbols.forEach((key, value) {
        var quote = key.split('/')[0];
        var base = key.split('/')[1];
        var market = '${quote.toLowerCase()}${base.toLowerCase()}';
        var kLineEntity = fromSymbolToKLineEntity(value);
        var marketItem = MarketItemEntity(
          market,
          kLineEntity,
          base: base,
          quote: quote,
        );
        marketItemList.add(marketItem);
      });
    } catch (e) {
      print('[ MarketSymbolList.fromJson] $e');
    }
    return marketItemList;
  }

  static KLineEntity fromSymbolToKLineEntity(List itemList) {
    Map<String, dynamic> json = {
      'open': double.parse(itemList[1].toString()),
      'high': double.parse(itemList[2].toString()),
      'low': double.parse(itemList[3].toString()),
      'close': double.parse(itemList[4].toString()),
      'vol': double.parse(itemList[5].toString()),
      'amount': double.parse(itemList[6].toString()),
      'count': 0,
      'id': 0,
    };
    return KLineEntity.fromJson(json);
  }
}
