import 'package:json_annotation/json_annotation.dart';

part 'symbol_quote_vo.g.dart';

@JsonSerializable()
class SymbolQuoteVo {
  ///ETH, HYN etc..
  String symbol;

  ///USD, CNY etc..
  final String quote;

  ///the symbol base quote price
  final double price;

  final double percentChange24h;

  SymbolQuoteVo({this.symbol, this.quote, this.price, this.percentChange24h});

  factory SymbolQuoteVo.fromJson(Map<String, dynamic> json) => _$SymbolQuoteVoFromJson(json);

  Map<String, dynamic> toJson() => _$SymbolQuoteVoToJson(this);

  factory SymbolQuoteVo.clone(SymbolQuoteVo obj) {
    return SymbolQuoteVo(
      price: obj.price,
      percentChange24h: obj.percentChange24h,
      quote: obj.quote,
      symbol: obj.symbol,
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  List<Object> get props => [symbol, quote, price, percentChange24h];
}
