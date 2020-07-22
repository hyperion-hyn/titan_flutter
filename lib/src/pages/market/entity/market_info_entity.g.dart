// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_info_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketInfoEntity _$MarketInfoEntityFromJson(Map<String, dynamic> json) {
  return MarketInfoEntity(
    int.parse(json['amount_precision'] ?? 8),
    int.parse(json['price_precision'] ?? 8),
    int.parse(json['turnover_precision'] ?? 8),
    (json['depth_precision'] as List)?.map((e) => e as int)?.toList(),
  );
}

Map<String, dynamic> _$MarketInfoEntityToJson(MarketInfoEntity instance) =>
    <String, dynamic>{
      'amount_precision': instance.amountPrecision,
      'price_precision': instance.pricePrecision,
      'turnover_precision': instance.turnoverPrecision,
      'depth_precision': instance.depthPrecision,
    };
