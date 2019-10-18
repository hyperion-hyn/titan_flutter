// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) {
  return UserInfo(
    json['id'] as String,
    json['email'] as String,
    json['parent_id'] as String,
    (json['balance'] as num)?.toDouble(),
    (json['charge_balance'] as num)?.toDouble(),
    json['total_power'] as int,
    json['mortgage_nodes'] as int,
    json['highest_power'] as int,
    json['second_highest_power'] as int,
    json['low_power'] as int,
    json['total_invitations'] as int,
    json['level'] as String,
  );
}

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'parent_id': instance.parentId,
      'balance': instance.balance,
      'charge_balance': instance.chargeBalance,
      'total_power': instance.totalPower,
      'mortgage_nodes': instance.mortgageNodes,
      'highest_power': instance.highestPower,
      'second_highest_power': instance.secondHighestPower,
      'low_power': instance.lowPower,
      'total_invitations': instance.totalInvitations,
      'level': instance.level,
    };
