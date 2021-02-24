// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_coin_list_v2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExchangeCoinListV2 _$ExchangeCoinListFromJson(Map<String, dynamic> json) {
  return ExchangeCoinListV2(
    (json['assets'] as List)?.map((e) => e as String)?.toList(),
    json['activeExchangeMap'] as Map<String, dynamic>,
    (json['tokens'] as List)
        ?.map((e) => e == null ? null : Token.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ExchangeCoinListToJson(ExchangeCoinListV2 instance) => <String, dynamic>{
      'assets': instance.assets,
      'activeExchangeMap': instance.activeExchangeMap,
      'tokens': instance.tokens,
    };

Token _$TokenFromJson(Map<String, dynamic> json) {
  return Token(
    json['symbol'] as String,
    json['coinType'] as int,
    json['chain'] as String,
  );
}

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
      'symbol': instance.symbol,
      'coinType': instance.coinType,
      'chain': instance.chain,
    };
