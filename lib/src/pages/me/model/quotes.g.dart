// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quotes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Quotes _$QuotesFromJson(Map<String, dynamic> json) {
  return Quotes(
    json['currency'] as String,
    json['to'] as String,
    (json['rate'] as num)?.toDouble(),
    (json['avgRate'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$QuotesToJson(Quotes instance) => <String, dynamic>{
      'currency': instance.currency,
      'to': instance.to,
      'rate': instance.rate,
      'avgRate': instance.avgRate,
    };
