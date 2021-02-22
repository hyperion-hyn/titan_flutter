import 'package:json_annotation/json_annotation.dart';

part 'exchange_coin_list_v2.g.dart';

@JsonSerializable()
class ExchangeCoinListV2 extends Object {
  @JsonKey(name: 'base')
  List<String> assets;

  @JsonKey(name: 'activeExchangeMap')
  Map<String, dynamic> activeExchangeMap;

  @JsonKey(name: 'tokens')
  List<Token> tokens;

  ExchangeCoinListV2(
    this.assets,
    this.activeExchangeMap,
    this.tokens,
  );

  factory ExchangeCoinListV2.fromJson(Map<String, dynamic> srcJson) =>
      _$ExchangeCoinListFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ExchangeCoinListToJson(this);
}

@JsonSerializable()
class Token extends Object {

  @JsonKey(name: 'symbol')
  String symbol;

  @JsonKey(name: 'coinType')
  int coinType;

  @JsonKey(name: 'chain')
  String chain;

  Token(this.symbol,this.coinType,this.chain,);

  factory Token.fromJson(Map<String, dynamic> srcJson) => _$TokenFromJson(srcJson);

  Map<String, dynamic> toJson() => _$TokenToJson(this);

}
