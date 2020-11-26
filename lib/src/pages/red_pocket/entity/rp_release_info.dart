import 'package:json_annotation/json_annotation.dart'; 
  
part 'rp_release_info.g.dart';


@JsonSerializable()
  class RpReleaseInfo extends Object {

  @JsonKey(name: 'staking_id')
  int stakingId;

  @JsonKey(name: 'staking_at')
  int stakingAt;

  @JsonKey(name: 'hyn_amount')
  String hynAmount;

  @JsonKey(name: 'rp_amount')
  String rpAmount;

  @JsonKey(name: 'updated_at')
  int updatedAt;

  @JsonKey(name: 'amount')
  int amount;

  RpReleaseInfo(this.stakingId,this.stakingAt,this.hynAmount,this.rpAmount,this.updatedAt,this.amount,);

  factory RpReleaseInfo.fromJson(Map<String, dynamic> srcJson) => _$RpReleaseInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpReleaseInfoToJson(this);

}

  
