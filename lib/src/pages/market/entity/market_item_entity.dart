import 'package:flutter/material.dart';
import 'package:k_chart/flutter_k_chart.dart';

class MarketItemEntity {
  String symbol;
  String symbolName;
  String base;
  String quote;
  KLineEntity kLineEntity;

  MarketItemEntity(
    this.symbol,
    this.kLineEntity, {
    @required this.base,
    @required this.quote,
    this.symbolName,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['symbol'] = this.symbol;
    data['symbolName'] = this.symbolName;
    data['base'] = this.base;
    data['quote'] = this.quote;
    data['kLineEntity'] = this.kLineEntity?.toJson();
    return data;
  }

  MarketItemEntity.fromJson(Map<String, dynamic> json) {
    try {
      symbol = json['symbol'];
      symbolName = json['symbolName'];
      base = json['base'];
      quote = json['quote'];
      kLineEntity = KLineEntity.fromJson(json['kLineEntity']);
    } catch (e) {}
  }
}
