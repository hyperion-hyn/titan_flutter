// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_price_view_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenPriceViewVo _$TokenPriceViewVoFromJson(Map<String, dynamic> json) {
  return TokenPriceViewVo(
    symbol: json['symbol'] as String,
    legal: json['legal'] == null
        ? null
        : LegalSign.fromJson(json['legal'] as Map<String, dynamic>),
    price: (json['price'] as num)?.toDouble(),
    percentChange24h: (json['percentChange24h'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$TokenPriceViewVoToJson(TokenPriceViewVo instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'legal': instance.legal?.toJson(),
      'price': instance.price,
      'percentChange24h': instance.percentChange24h,
    };
