import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';

import 'vo/symbol_quote_vo.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

class QuotesModel extends Equatable {
  final String symbolStr;
  final List<SymbolQuoteVo> quotes;
  final int lastUpdateTime;

  QuotesModel({this.symbolStr, this.quotes, this.lastUpdateTime});

  @override
  List<Object> get props => [symbolStr, quotes, lastUpdateTime];
}

@JsonSerializable()
class QuotesSign extends Object {
  @JsonKey(name: 'quote')
  String quote;

  @JsonKey(name: 'sign')
  String sign;

  QuotesSign({this.quote, this.sign});

  factory QuotesSign.fromJson(Map<String, dynamic> srcJson) => _$QuotesSignFromJson(srcJson);

  Map<String, dynamic> toJson() => _$QuotesSignToJson(this);
}

class ActiveQuoteVoAndSign {
  final SymbolQuoteVo quoteVo;
  final QuotesSign sign;

  ActiveQuoteVoAndSign({this.quoteVo, this.sign});
}

class SupportedQuoteSigns {
  static QuotesSign defaultQuotesSign = QuotesSign(quote: 'USD', sign: '\$');

  static List<QuotesSign> all = [
    defaultQuotesSign,
    QuotesSign(quote: 'CNY', sign: '¥'),
  ];

  static QuotesSign of(String quotes) {
    for (var sign in all) {
      if (sign.quote == quotes) {
        return sign;
      }
    }
    return defaultQuotesSign;
  }
}

@JsonSerializable()
class GasPriceRecommend extends Object {

  @JsonKey(name: 'fast')
  Decimal fast;

  @JsonKey(name: 'fastWait')
  double fastWait;

  @JsonKey(name: 'average')
  Decimal average;

  @JsonKey(name: 'avgWait')
  double avgWait;

  @JsonKey(name: 'safeLow')
  Decimal safeLow;

  @JsonKey(name: 'safeLowWait')
  double safeLowWait;

  GasPriceRecommend(this.fast,this.fastWait,this.average,this.avgWait,this.safeLow,this.safeLowWait,);

  factory GasPriceRecommend.fromJson(Map<String, dynamic> srcJson) => _$GasPriceRecommendFromJson(srcJson);

  Map<String, dynamic> toJson() => _$GasPriceRecommendToJson(this);

  GasPriceRecommend.defaultValue() {
    this.fast = Decimal.fromInt(EthereumConst.SUPER_FAST_SPEED);
    this.average = Decimal.fromInt(EthereumConst.FAST_SPEED);
    this.safeLow = Decimal.fromInt(EthereumConst.LOW_SPEED);
    this.fastWait = 0.5;
    this.avgWait = 3;
    this.safeLowWait = 30;
  }

}

GasPriceRecommend _$GasPriceRecommendFromJson(Map<String, dynamic> json) {
  return GasPriceRecommend(
    Decimal.parse(json['fast']),
    (json['fastWait'] as num)?.toDouble(),
    Decimal.parse(json['average']),
    (json['avgWait'] as num)?.toDouble(),
    Decimal.parse(json['safeLow']),
    (json['safeLowWait'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$GasPriceRecommendToJson(GasPriceRecommend instance) =>
    <String, dynamic>{
      'fast': instance.fast.toString(),
      'fastWait': instance.fastWait,
      'average': instance.average.toString(),
      'avgWait': instance.avgWait,
      'safeLow': instance.safeLow.toString(),
      'safeLowWait': instance.safeLowWait,
    };

@JsonSerializable()
class BTCGasPriceRecommend extends Object {

  @JsonKey(name: 'fast')
  Decimal fast;

  @JsonKey(name: 'fastWait')
  double fastWait;

  @JsonKey(name: 'average')
  Decimal average;

  @JsonKey(name: 'avgWait')
  double avgWait;

  @JsonKey(name: 'safeLow')
  Decimal safeLow;

  @JsonKey(name: 'safeLowWait')
  double safeLowWait;

  BTCGasPriceRecommend(this.fast,this.fastWait,this.average,this.avgWait,this.safeLow,this.safeLowWait,);

  factory BTCGasPriceRecommend.fromJson(Map<String, dynamic> srcJson) => _$BTCGasPriceRecommendFromJson(srcJson);

  Map<String, dynamic> toJson() => _$BTCGasPriceRecommendToJson(this);

  BTCGasPriceRecommend.defaultValue(){
    this.fast = Decimal.fromInt(BitcoinConst.BTC_SUPER_FAST_SPEED);
    this.average = Decimal.fromInt(BitcoinConst.BTC_FAST_SPEED);
    this.safeLow = Decimal.fromInt(BitcoinConst.BTC_LOW_SPEED);
    this.fastWait = 15;
    this.avgWait = 45;
    this.safeLowWait = 70;
  }
}

BTCGasPriceRecommend _$BTCGasPriceRecommendFromJson(Map<String, dynamic> json) {
  return BTCGasPriceRecommend(
    Decimal.parse(json['fast']),
    (json['fastWait'] as num)?.toDouble(),
    Decimal.parse(json['average']),
    (json['avgWait'] as num)?.toDouble(),
    Decimal.parse(json['safeLow']),
    (json['safeLowWait'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$BTCGasPriceRecommendToJson(BTCGasPriceRecommend instance) =>
    <String, dynamic>{
      'fast': instance.fast.toString(),
      'fastWait': instance.fastWait,
      'average': instance.average.toString(),
      'avgWait': instance.avgWait,
      'safeLow': instance.safeLow.toString(),
      'safeLowWait': instance.safeLowWait,
    };