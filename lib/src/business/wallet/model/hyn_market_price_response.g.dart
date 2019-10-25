// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hyn_market_price_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HynMarketPriceResponse _$HynMarketPriceResponseFromJson(
    Map<String, dynamic> json) {
  return HynMarketPriceResponse(
    (json['avgPrice'] as num)?.toDouble(),
    (json['avgCNYPrice'] as num)?.toDouble(),
    (json['markets'] as List)
        ?.map((e) => e == null
            ? null
            : HynMarketPriceInfo.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['total'] as int,
  );
}

Map<String, dynamic> _$HynMarketPriceResponseToJson(
        HynMarketPriceResponse instance) =>
    <String, dynamic>{
      'avgPrice': instance.avgPrice,
      'avgCNYPrice': instance.avgCNYPrice,
      'markets': instance.markets,
      'total': instance.total,
    };
