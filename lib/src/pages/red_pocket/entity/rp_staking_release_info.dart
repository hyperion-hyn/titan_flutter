import 'package:json_annotation/json_annotation.dart';

part 'rp_staking_release_info.g.dart';

@JsonSerializable()
class RpStakingReleaseInfo extends Object {
  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'created_at')
  String createdAt;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  @JsonKey(name: 'staking_at')
  String stakingAt;

  @JsonKey(name: 'tx_hash')
  String txHash;

  @JsonKey(name: 'staking_id')
  int stakingId;

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'hyn_amount')
  String hynAmount;

  @JsonKey(name: 'release_rp')
  String releaseRp;

  @JsonKey(name: 'release_times')
  int releaseTimes;

  @JsonKey(name: 'release_limit')
  int releaseLimit;

  @JsonKey(name: 'expect_retrieve_time')
  String expectRetrieveTime;

  @JsonKey(name: 'status')
  int status;

  @JsonKey(name: 'rp_amount')
  String rpAmount;

  @JsonKey(name: 'amount')
  int amount;

  RpStakingReleaseInfo(
    this.id,
    this.createdAt,
    this.updatedAt,
    this.stakingAt,
    this.txHash,
    this.stakingId,
    this.address,
    this.hynAmount,
    this.releaseRp,
    this.releaseTimes,
    this.releaseLimit,
    this.expectRetrieveTime,
    this.status,
    this.rpAmount,
    this.amount,
  );

  factory RpStakingReleaseInfo.fromJson(Map<String, dynamic> srcJson) => _$RpStakingReleaseInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpStakingReleaseInfoToJson(this);
}
