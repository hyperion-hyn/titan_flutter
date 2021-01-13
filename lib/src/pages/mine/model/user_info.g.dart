// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) {
  return UserInfo(
    id: json['id'] as String,
    email: json['email'] as String,
    bindAddress: json['bind_address'] as String,
    parentId: json['parent_id'] as String,
    balance: (json['balance'] as num)?.toDouble(),
    chargeHynBalance: (json['charge_balance'] as num)?.toDouble(),
    totalPower: (json['total_power'] as num).toDouble(),
    mortgageNodes: json['mortgage_nodes'] as int,
    highestPower: (json['highest_power'] as num)?.toDouble(),
    secondHighestPower: (json['second_highest_power'] as num)?.toDouble(),
    lowPower: (json['low_power'] as num)?.toDouble(),
    totalInvitations: json['total_invitations'] as int,
    level: json['level'] as String,
    numOfTeamMember: json['num_of_team_member'] as int,
    parentUser: json['parent_user'] == null ? null : ParentUser.fromJson(json['parent_user'] as Map<String, dynamic>),
    directlyPower: (json['directly_power'] as num)?.toDouble(),
    chargeUsdtBalance: (json['charge_usdt_balance'] as num)?.toDouble(),
    totalChargeBalance: (json['total_charge_balance'] as num)?.toDouble(),
    levelNum: json['level_num'] as int,
    canStakingLevel: json['can_staking_level'] as int,
    canStaking: json['can_staking'] as bool,
    walletAddr: json['walletAddr'] as String,
    hynBalance: (json['hyn_balance'] as num)?.toDouble(),
    effectiveAcceleration: (json['effective_acceleration'] as num)?.toDouble(),
    totalReward: (json['total_reward'] as num)?.toDouble(),
    yesterdayReward: (json['yesterday_reward'] as num)?.toDouble(),
    totalMiner: json['total_miner'] as int,
    globalEffective: (json['global_effective'] as num)?.toDouble(),
    maxWithdrawCount: json['max_withdraw_count'] as int,
    canWithdrawCount: json['can_withdraw_count'] as int,
    minWithdraw: (json['min_withdraw'] as num)?.toDouble(),
    rewardPool: (json['reward_pool'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'bind_address': instance.bindAddress,
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
      'walletAddr': instance.walletAddr,
      'hyn_balance': instance.hynBalance,
      'effective_acceleration': instance.effectiveAcceleration,
      'total_reward': instance.totalReward,
      'yesterday_reward': instance.yesterdayReward,
      'total_miner': instance.totalMiner,
      'global_effective': instance.globalEffective,
      'max_withdraw_count': instance.maxWithdrawCount,
      'can_withdraw_count': instance.canWithdrawCount,
      'min_withdraw': instance.minWithdraw,
      'reward_pool': instance.rewardPool,
    };
