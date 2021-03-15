// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cross_chain_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CrossChainToken _$CrossChainTokenFromJson(Map<String, dynamic> json) {
  return CrossChainToken(
    json['symbol'] as String,
    json['atlas_token_address'] as String,
    json['heco_token_address'] as String,
  );
}

Map<String, dynamic> _$CrossChainTokenToJson(CrossChainToken instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'atlas_token_address': instance.atlasTokenAddress,
      'heco_token_address': instance.hecoTokenAddress,
    };
