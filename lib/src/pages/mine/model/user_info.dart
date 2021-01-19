import 'package:json_annotation/json_annotation.dart';

import 'parent_user.dart';

part 'user_info.g.dart';

@JsonSerializable()
class UserInfo {
  @JsonKey(name: "id")
  String id;
  @JsonKey(name: "email")
  String email;
  @JsonKey(name: "bind_address")
  String bindAddress;
  @JsonKey(name: "parent_id")
  String parentId;
  @JsonKey(name: "balance")
  double balance;
  @JsonKey(name: "charge_balance")
  double chargeHynBalance;
  @JsonKey(name: "charge_usdt_balance")
  double chargeUsdtBalance;
  @JsonKey(name: "total_charge_balance")
  double totalChargeBalance;
  @JsonKey(name: "total_power")
  double totalPower;
  @JsonKey(name: "mortgage_nodes")
  int mortgageNodes;
  @JsonKey(name: "highest_power")
  double highestPower;
  @JsonKey(name: "second_highest_power")
  double secondHighestPower;
  @JsonKey(name: "low_power")
  double lowPower;
  @JsonKey(name: "total_invitations")
  int totalInvitations;
  @JsonKey(name: "level")
  String level;
  @JsonKey(name: "num_of_team_member")
  int numOfTeamMember;
  @JsonKey(name: "parent_user")
  ParentUser parentUser;
  @JsonKey(name: "directly_power")
  double directlyPower;
  @JsonKey(name: "level_num")
  int levelNum;
  @JsonKey(name: "can_staking_level")
  int canStakingLevel;
  @JsonKey(name: "can_staking")
  bool canStaking;
  @JsonKey(name: "walletAddr")
  String walletAddr;
  @JsonKey(name: "hyn_balance")
  double hynBalance;
  @JsonKey(name: "effective_acceleration")
  double effectiveAcceleration;
  @JsonKey(name: "total_reward")
  double totalReward;
  @JsonKey(name: "yesterday_reward")
  double yesterdayReward;
  @JsonKey(name: "total_miner")
  int totalMiner;
  @JsonKey(name: "global_effective")
  double globalEffective;
  @JsonKey(name: "max_withdraw_count")
  int maxWithdrawCount;
  @JsonKey(name: "can_withdraw_count")
  int canWithdrawCount;
  @JsonKey(name: "min_withdraw")
  double minWithdraw;
  @JsonKey(name: "reward_pool")
  double rewardPool;

  UserInfo({
    this.id,
    this.email,
    this.bindAddress,
    this.parentId,
    this.balance,
    this.chargeHynBalance,
    this.totalPower,
    this.mortgageNodes,
    this.highestPower,
    this.secondHighestPower,
    this.lowPower,
    this.totalInvitations,
    this.level,
    this.numOfTeamMember,
    this.parentUser,
    this.directlyPower,
    this.chargeUsdtBalance,
    this.totalChargeBalance,
    this.levelNum,
    this.canStakingLevel,
    this.canStaking,
    this.walletAddr,
    this.hynBalance,
    this.totalReward,
    this.effectiveAcceleration,
    this.totalMiner,
    this.yesterdayReward,
    this.globalEffective,
    this.canWithdrawCount,
    this.maxWithdrawCount,
    this.minWithdraw,
    this.rewardPool,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}
