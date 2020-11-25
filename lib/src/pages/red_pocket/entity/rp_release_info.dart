import 'package:json_annotation/json_annotation.dart';

part 'rp_release_info.g.dart';


@JsonSerializable()
class RPReleaseInfo extends Object {

  @JsonKey(name: 'amount')
  int amount;

  @JsonKey(name: 'hyn_amount')
  int hynAmount;

  @JsonKey(name: 'rp_amount')
  int rpAmount;

  @JsonKey(name: 'staking_at')
  String stakingAt;

  @JsonKey(name: 'staking_id')
  int stakingId;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  RPReleaseInfo(this.amount,this.hynAmount,this.rpAmount,this.stakingAt,this.stakingId,this.updatedAt,);

  factory RPReleaseInfo.fromJson(Map<String, dynamic> srcJson) => _$RPReleaseInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RPReleaseInfoToJson(this);

}


