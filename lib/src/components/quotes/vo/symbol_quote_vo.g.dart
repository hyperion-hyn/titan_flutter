// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'symbol_quote_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SymbolQuoteVo _$SymbolQuoteVoFromJson(Map<String, dynamic> json) {
  return SymbolQuoteVo(
    symbol: json['symbol'] as String,
    quote: json['quote'] as String,
    price: (json['price'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$SymbolQuoteVoToJson(SymbolQuoteVo instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'quote': instance.quote,
      'price': instance.price,
    };
