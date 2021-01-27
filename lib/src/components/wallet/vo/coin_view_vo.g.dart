// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_view_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinViewVo _$CoinViewVoFromJson(Map<String, dynamic> json) {
  return CoinViewVo(
    decimals: json['decimals'] as int,
    name: json['name'] as String,
    symbol: json['symbol'] as String,
    logo: json['logo'] as String,
    address: json['address'] as String,
    contractAddress: json['contractAddress'] as String,
    extendedPublicKey: json['extendedPublicKey'] as String,
    balance: json['balance'] == null
        ? null
        : BigInt.parse(json['balance'] as String),
    coinType: json['coinType'] as int,
    refreshStatus: _$enumDecodeNullable(_$StatusEnumMap, json['refreshStatus']),
  );
}

Map<String, dynamic> _$CoinViewVoToJson(CoinViewVo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'symbol': instance.symbol,
      'logo': instance.logo,
      'address': instance.address,
      'contractAddress': instance.contractAddress,
      'extendedPublicKey': instance.extendedPublicKey,
      'decimals': instance.decimals,
      'coinType': instance.coinType,
      'balance': instance.balance?.toString(),
      'refreshStatus': _$StatusEnumMap[instance.refreshStatus],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$StatusEnumMap = {
  Status.idle: 'idle',
  Status.loading: 'loading',
  Status.success: 'success',
  Status.failed: 'failed',
  Status.cancelled: 'cancelled',
};
