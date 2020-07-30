import 'package:flutter_k_chart/entity/k_line_entity.dart';

class MarketItemEntity {
  String symbol;
  String symbolName;
  KLineEntity kLineEntity;

  MarketItemEntity(
    this.symbol,
    this.kLineEntity, {
    this.symbolName,
  });
}
