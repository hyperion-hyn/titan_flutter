import 'package:json_annotation/json_annotation.dart';

part 'exchange_coin_list.g.dart';

@JsonSerializable()
class ExchangeCoinList extends Object {
  @JsonKey(name: 'base')
  List<String> assets;

  @JsonKey(name: 'activeExchangeMap')
  Map<String, dynamic> activeExchangeMap;

  ExchangeCoinList(
    this.assets,
    this.activeExchangeMap,
  );

  factory ExchangeCoinList.fromJson(Map<String, dynamic> srcJson) =>
      _$ExchangeCoinListFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ExchangeCoinListToJson(this);
}
