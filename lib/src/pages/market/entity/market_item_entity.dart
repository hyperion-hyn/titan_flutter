
import 'package:k_chart/flutter_k_chart.dart';

class MarketItemEntity {
  String symbol;
  String symbolName;
  KLineEntity kLineEntity;

  MarketItemEntity(
    this.symbol,
    this.kLineEntity, {
    this.symbolName,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['symbol'] = this.symbol;
    data['symbolName'] = this.symbolName;
    data['kLineEntity'] = this.kLineEntity?.toJson();
    return data;
  }

  MarketItemEntity.fromJson(Map<String, dynamic> json) {
    try {
      symbol = json['symbol'];
      symbolName = json['symbolName'];
      kLineEntity = KLineEntity.fromJson(json['kLineEntity']);
    } catch (e) {}
  }
}
