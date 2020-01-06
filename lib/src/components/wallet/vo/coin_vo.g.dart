// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinVo _$CoinVoFromJson(Map<String, dynamic> json) {
  return CoinVo(
    decimals: json['decimals'] as int,
    name: json['name'] as String,
    symbol: json['symbol'] as String,
    logo: json['logo'] as String,
    address: json['address'] as String,
    contractAddress: json['contractAddress'] as String,
    balance: (json['balance'] as num)?.toDouble(),
    coinType: json['coinType'] as int,
  );
}

Map<String, dynamic> _$CoinVoToJson(CoinVo instance) => <String, dynamic>{
      'name': instance.name,
      'symbol': instance.symbol,
      'logo': instance.logo,
      'address': instance.address,
      'contractAddress': instance.contractAddress,
      'decimals': instance.decimals,
      'coinType': instance.coinType,
      'balance': instance.balance,
    };
