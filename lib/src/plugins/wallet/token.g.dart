// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetToken _$AssetTokenFromJson(Map<String, dynamic> json) {
  return AssetToken(
    name: json['name'] as String,
    decimals: json['decimals'] as int,
    erc20ContractAddress: json['erc20ContractAddress'] as String,
    symbol: json['symbol'] as String,
    logo: json['logo'] as String,
  );
}

Map<String, dynamic> _$AssetTokenToJson(AssetToken instance) =>
    <String, dynamic>{
      'decimals': instance.decimals,
      'name': instance.name,
      'symbol': instance.symbol,
      'logo': instance.logo,
      'erc20ContractAddress': instance.erc20ContractAddress,
    };
