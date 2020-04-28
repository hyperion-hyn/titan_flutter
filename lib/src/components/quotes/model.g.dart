// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuotesSign _$QuotesSignFromJson(Map<String, dynamic> json) {
  return QuotesSign(
    quote: json['quote'] as String,
    sign: json['sign'] as String,
  );
}

Map<String, dynamic> _$QuotesSignToJson(QuotesSign instance) =>
    <String, dynamic>{
      'quote': instance.quote,
      'sign': instance.sign,
    };
