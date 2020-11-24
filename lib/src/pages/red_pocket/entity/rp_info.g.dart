// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RPInfo _$RPInfoFromJson(Map<String, dynamic> json) {
  return RPInfo(
    json['level'] as String,
    json['balance'] as String,
    json['rp_balance'] as String,
    json['rp_today'] as String,
    json['rp_yesterday'] as String,
    json['rp_missed'] as String,
  );
}

Map<String, dynamic> _$RPInfoToJson(RPInfo instance) => <String, dynamic>{
      'level': instance.level,
      'balance': instance.balance,
      'rp_balance': instance.rpBalance,
      'rp_today': instance.rpToday,
      'rp_yesterday': instance.rpYesterday,
      'rp_missed': instance.rpMissed,
    };
