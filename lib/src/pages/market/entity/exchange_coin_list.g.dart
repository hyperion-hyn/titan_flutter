// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_coin_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExchangeCoinList _$ExchangeCoinListFromJson(Map<String, dynamic> json) {
  return ExchangeCoinList(
    (json['assets'] as List)?.map((e) => e as String)?.toList(),
    json['activeExchangeMap'] == null
        ? null
        : json['activeExchangeMap'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$ExchangeCoinListToJson(ExchangeCoinList instance) =>
    <String, dynamic>{
      'assets': instance.assets,
      'activeExchangeMap': instance.activeExchangeMap,
    };
