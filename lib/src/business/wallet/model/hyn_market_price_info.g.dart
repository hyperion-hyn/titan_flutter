// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hyn_market_price_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HynMarketPriceInfo _$HynMarketPriceInfoFromJson(Map<String, dynamic> json) {
  return HynMarketPriceInfo(
    json['source'] as String,
    json['icon'] as String,
    json['tx_pair'] as String,
    (json['price'] as num)?.toDouble(),
    json['is_best'] as bool,
    json['url'] as String,
  );
}

Map<String, dynamic> _$HynMarketPriceInfoToJson(HynMarketPriceInfo instance) =>
    <String, dynamic>{
      'source': instance.source,
      'icon': instance.icon,
      'tx_pair': instance.txPair,
      'price': instance.price,
      'is_best': instance.isBest,
      'url': instance.url,
    };
