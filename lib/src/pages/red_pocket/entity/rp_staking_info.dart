import 'package:json_annotation/json_annotation.dart';

part 'rp_staking_info.g.dart';


@JsonSerializable()
class RPStakingInfo extends Object {

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'created_at')
  String createdAt;

  @JsonKey(name: 'hyn_amount')
  int hynAmount;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'staking_id')
  int stakingId;

  @JsonKey(name: 'status')
  int status;

  @JsonKey(name: 'tx_hash')
  String txHash;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  RPStakingInfo(this.address,this.createdAt,this.hynAmount,this.id,this.stakingId,this.status,this.txHash,this.updatedAt,);

  factory RPStakingInfo.fromJson(Map<String, dynamic> srcJson) => _$RPStakingInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RPStakingInfoToJson(this);

}


