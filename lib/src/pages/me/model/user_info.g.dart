// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) {
  return UserInfo(
    id: json['id'] as String,
    email: json['email'] as String,
    parentId: json['parent_id'] as String,
    balance: (json['balance'] as num)?.toDouble(),
    chargeHynBalance: (json['charge_balance'] as num)?.toDouble(),
    totalPower: json['total_power'] as int,
    mortgageNodes: json['mortgage_nodes'] as int,
    highestPower: json['highest_power'] as int,
    secondHighestPower: json['second_highest_power'] as int,
    lowPower: json['low_power'] as int,
    totalInvitations: json['total_invitations'] as int,
    level: json['level'] as String,
    numOfTeamMember: json['num_of_team_member'] as int,
    parentUser: json['parent_user'] == null
        ? null
        : ParentUser.fromJson(json['parent_user'] as Map<String, dynamic>),
    directlyPower: json['directly_power'] as int,
    chargeUsdtBalance: (json['charge_usdt_balance'] as num)?.toDouble(),
    totalChargeBalance: (json['total_charge_balance'] as num)?.toDouble(),
    levelNum: json['level_num'] as int,
    canStakingLevel: json['can_staking_level'] as int,
    canStaking: json['can_staking'] as bool,
  );
}

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'parent_id': instance.parentId,
      'balance': instance.balance,
      'charge_balance': instance.chargeHynBalance,
      'charge_usdt_balance': instance.chargeUsdtBalance,
      'total_charge_balance': instance.totalChargeBalance,
      'total_power': instance.totalPower,
      'mortgage_nodes': instance.mortgageNodes,
      'highest_power': instance.highestPower,
      'second_highest_power': instance.secondHighestPower,
      'low_power': instance.lowPower,
      'total_invitations': instance.totalInvitations,
      'level': instance.level,
      'num_of_team_member': instance.numOfTeamMember,
      'parent_user': instance.parentUser,
      'directly_power': instance.directlyPower,
      'level_num': instance.levelNum,
      'can_staking_level': instance.canStakingLevel,
      'can_staking': instance.canStaking,
    };
