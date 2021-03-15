import 'package:json_annotation/json_annotation.dart';

part 'cross_chain_token.g.dart';


@JsonSerializable()
class CrossChainToken extends Object {

  @JsonKey(name: 'symbol')
  String symbol;

  @JsonKey(name: 'atlas_token_address')
  String atlasTokenAddress;

  @JsonKey(name: 'heco_token_address')
  String hecoTokenAddress;

  CrossChainToken(this.symbol,this.atlasTokenAddress,this.hecoTokenAddress,);

  factory CrossChainToken.fromJson(Map<String, dynamic> srcJson) => _$CrossChainTokenFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CrossChainTokenToJson(this);

}


