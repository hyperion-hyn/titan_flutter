// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_info_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketInfoEntity _$MarketInfoEntityFromJson(Map<String, dynamic> json) {
  return MarketInfoEntity(
    json['amount_precision'] as int,
    json['price_precision'] as int,
    json['turnover_precision'] as int,
    json['amount_max'] as int,
    (json['amount_min'] as num)?.toDouble(),
    (json['depth_precision'] as List)?.map((e) => e as int)?.toList(),
  )
    ..bestBid = json['best_bid'] as int
    ..bestAsk = json['best_ask'] as int
    ..feeRate = (json['fee_rate'] as num)?.toDouble()
    ..feeRateReadable = (json['fee_rate_readable'] as num)?.toDouble();
}

Map<String, dynamic> _$MarketInfoEntityToJson(MarketInfoEntity instance) =>
    <String, dynamic>{
      'best_bid': instance.bestBid,
      'best_ask': instance.bestAsk,
      'amount_precision': instance.amountPrecision,
      'price_precision': instance.pricePrecision,
      'amount_max': instance.amountMax,
      'amount_min': instance.amountMin,
      'fee_rate': instance.feeRate,
      'fee_rate_readable': instance.feeRateReadable,
      'turnover_precision': instance.turnoverPrecision,
      'depth_precision': instance.depthPrecision,
    };
