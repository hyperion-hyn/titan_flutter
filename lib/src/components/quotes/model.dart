import 'package:equatable/equatable.dart';

import 'vo/symbol_quote_vo.dart';

class QuotesModel extends Equatable {
  final String symbolStr;
  final List<SymbolQuoteVo> quotes;
  final int lastUpdateTime;

  QuotesModel({this.symbolStr, this.quotes, this.lastUpdateTime});

  @override
  List<Object> get props => [symbolStr, quotes, lastUpdateTime];
}

class QuotesSign {
  final String quote;
  final String sign;

  QuotesSign({this.quote, this.sign});
}

class ActiveQuoteVoAndSign {
  final SymbolQuoteVo quoteVo;
  final QuotesSign sign;

  ActiveQuoteVoAndSign({this.quoteVo, this.sign});
}

class SupportedQuoteSigns {
  static QuotesSign _defaultQuotesSign = QuotesSign(quote: 'USD', sign: '\$');

  static List<QuotesSign> all = [
    _defaultQuotesSign,
    QuotesSign(quote: 'CNY', sign: '¥'),
  ];

  static QuotesSign of(String quotes) {
    for (var sign in all) {
      if (sign.quote == quotes) {
        return sign;
      }
    }
    return _defaultQuotesSign;
  }
}
