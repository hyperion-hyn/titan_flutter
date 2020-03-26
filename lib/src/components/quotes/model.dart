import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

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

class GasPriceRecommend {
  final Decimal fast;
  final double fastWait;

  final Decimal average;
  final double avgWait;

  final Decimal safeLow;
  final double safeLowWait;

  GasPriceRecommend({
    this.average,
    this.fast,
    this.safeLow,
    this.avgWait,
    this.fastWait,
    this.safeLowWait,
  });
}
