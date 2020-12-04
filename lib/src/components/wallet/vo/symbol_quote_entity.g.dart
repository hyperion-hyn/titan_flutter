// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'symbol_quote_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SymbolQuoteEntity _$SymbolQuoteEntityFromJson(Map<String, dynamic> json) {
  return SymbolQuoteEntity(
    json['id'] as int,
    json['created_at'] as String,
    json['updated_at'] as String,
    (json['btc_cny_price'] as num)?.toDouble(),
    (json['btc_usd_price'] as num)?.toDouble(),
    (json['btc_percent_change_cny24h'] as num)?.toDouble(),
    (json['btc_percent_change_usd24h'] as num)?.toDouble(),
    (json['eth_cny_price'] as num)?.toDouble(),
    (json['eth_usd_price'] as num)?.toDouble(),
    (json['eth_percent_change_cny24h'] as num)?.toDouble(),
    (json['eth_percent_change_usd24h'] as num)?.toDouble(),
    (json['hyn_cny_price'] as num)?.toDouble(),
    (json['hyn_usd_price'] as num)?.toDouble(),
    (json['hyn_percent_change_cny24h'] as num)?.toDouble(),
    (json['hyn_percent_change_usd24h'] as num)?.toDouble(),
    (json['usdt_cny_price'] as num)?.toDouble(),
    (json['usdt_usd_price'] as num)?.toDouble(),
    (json['usdt_percent_change_cny24h'] as num)?.toDouble(),
    (json['usdt_percent_change_usd24h'] as num)?.toDouble(),
    (json['rp_cny_price'] as num)?.toDouble(),
    (json['rp_usd_price'] as num)?.toDouble(),
    (json['rp_percent_change_cny24h'] as num)?.toDouble(),
    (json['rp_percent_change_usd24h'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$SymbolQuoteEntityToJson(SymbolQuoteEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'btc_cny_price': instance.btcCnyPrice,
      'btc_usd_price': instance.btcUsdPrice,
      'btc_percent_change_cny24h': instance.btcPercentChangeCny24h,
      'btc_percent_change_usd24h': instance.btcPercentChangeUsd24h,
      'eth_cny_price': instance.ethCnyPrice,
      'eth_usd_price': instance.ethUsdPrice,
      'eth_percent_change_cny24h': instance.ethPercentChangeCny24h,
      'eth_percent_change_usd24h': instance.ethPercentChangeUsd24h,
      'hyn_cny_price': instance.hynCnyPrice,
      'hyn_usd_price': instance.hynUsdPrice,
      'hyn_percent_change_cny24h': instance.hynPercentChangeCny24h,
      'hyn_percent_change_usd24h': instance.hynPercentChangeUsd24h,
      'usdt_cny_price': instance.usdtCnyPrice,
      'usdt_usd_price': instance.usdtUsdPrice,
      'usdt_percent_change_cny24h': instance.usdtPercentChangeCny24h,
      'usdt_percent_change_usd24h': instance.usdtPercentChangeUsd24h,
      'rp_cny_price': instance.rpCnyPrice,
      'rp_usd_price': instance.rpUsdPrice,
      'rp_percent_change_cny24h': instance.rpPercentChangeCny24h,
      'rp_percent_change_usd24h': instance.rpPercentChangeUsd24h,
    };
