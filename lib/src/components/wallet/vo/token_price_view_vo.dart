import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/components/wallet/model.dart';

part 'token_price_view_vo.g.dart';

@JsonSerializable()
class TokenPriceViewVo {
  ///ETH, HYN etc..
  String symbol;

  final LegalSign legal;

  ///the symbol base quote price
  final double price;

  final double percentChange24h;

  TokenPriceViewVo({this.symbol, this.legal, this.price, this.percentChange24h});

  factory TokenPriceViewVo.fromJson(Map<String, dynamic> json) => _$TokenPriceViewVoFromJson(json);

  Map<String, dynamic> toJson() => _$TokenPriceViewVoToJson(this);

  factory TokenPriceViewVo.clone(TokenPriceViewVo obj) {
    return TokenPriceViewVo(
      price: obj.price,
      percentChange24h: obj.percentChange24h,
      legal: obj.legal,
      symbol: obj.symbol,
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }
// List<Object> get props => [symbol, legalSign, price, percentChange24h];
}
