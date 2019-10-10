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
    json['total_power'] as int,
    json['mortgage_nodes'] as int,
    json['high_power'] as int,
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
      'total_power': instance.totalPower,
      'mortgage_nodes': instance.mortgageNodes,
      'high_power': instance.highPower,
      'low_power': instance.lowPower,
      'total_invitations': instance.totalInvitations,
      'level': instance.level,
    };
