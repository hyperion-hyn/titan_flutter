import 'package:json_annotation/json_annotation.dart'; 
  
part 'rp_staking_info.g.dart';


@JsonSerializable()
  class RpStakingInfo extends Object {

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

  @JsonKey(name: 'expect_release_time')
  String expectReleaseTime;

  @JsonKey(name: 'status')
  int status;

  RpStakingInfo(this.id,this.createdAt,this.updatedAt,this.stakingAt,this.txHash,this.stakingId,this.address,this.hynAmount,this.releaseRp,this.releaseTimes,this.releaseLimit,this.expectReleaseTime,this.status,);

  factory RpStakingInfo.fromJson(Map<String, dynamic> srcJson) => _$RpStakingInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpStakingInfoToJson(this);

}

  
