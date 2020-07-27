import 'package:flutter_k_chart/entity/k_line_entity.dart';

class MarketSymbolList {
  String baseCurrency;
  List<KLineEntity> symbols;
  KLineEntity hynusdt;
  KLineEntity hyneth;
  KLineEntity hynbtc;

  MarketSymbolList.fromJson(dynamic response) {
    try {
      Map<String, dynamic> json =
          (response as List<dynamic>).last as Map<String, dynamic>;
      baseCurrency = json['baseCurrency'];
      Map<String, dynamic> symbols = json['symbols'];
      if (symbols.containsKey('HYN/USDT')) {
        hynusdt = KLineEntity.fromJson(symbols['HYN/USDT']);
      } else if (symbols.containsKey('HYN/ETH')) {
        hyneth = KLineEntity.fromJson(symbols['HYN/ETH']);
      } else if (symbols.containsKey('HYN/BTC')) {
        hynbtc = KLineEntity.fromJson(symbols['HYN/BTC']);
      }
    } catch (e) {
      print(e);
    }
  }
}
