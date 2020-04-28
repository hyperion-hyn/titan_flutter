import 'package:json_annotation/json_annotation.dart';

import 'parent_user.dart';

part 'user_info.g.dart';

@JsonSerializable()
class UserInfo {
  @JsonKey(name: "id")
  String id;
  @JsonKey(name: "email")
  String email;
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
  int totalPower;
  @JsonKey(name: "mortgage_nodes")
  int mortgageNodes;
  @JsonKey(name: "highest_power")
  int highestPower;
  @JsonKey(name: "second_highest_power")
  int secondHighestPower;
  @JsonKey(name: "low_power")
  int lowPower;
  @JsonKey(name: "total_invitations")
  int totalInvitations;
  @JsonKey(name: "level")
  String level;
  @JsonKey(name: "num_of_team_member")
  int numOfTeamMember;
  @JsonKey(name: "parent_user")
  ParentUser parentUser;
  @JsonKey(name: "directly_power")
  int directlyPower;
  @JsonKey(name: "level_num")
  int levelNum;
  @JsonKey(name: "can_staking_level")
  int canStakingLevel;
  @JsonKey(name: "can_staking")
  bool canStaking;

  UserInfo(
      {this.id,
      this.email,
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
      this.canStaking
      });

  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}
