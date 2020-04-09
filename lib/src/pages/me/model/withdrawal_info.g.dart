// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdrawal_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WithdrawalInfo _$WithdrawalInfoFromJson(Map<String, dynamic> json) {
  return WithdrawalInfo(
    (json['balance'] as num)?.toDouble(),
    (json['can_withdrawal'] as num)?.toDouble(),
    (json['free_rate'] as num)?.toDouble(),
    (json['has_withdrawal'] as num)?.toDouble(),
    (json['min_limit'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$WithdrawalInfoToJson(WithdrawalInfo instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'can_withdrawal': instance.can_withdrawal,
      'free_rate': instance.free_rate,
      'has_withdrawal': instance.has_withdrawal,
      'min_limit': instance.min_limit,
    };
