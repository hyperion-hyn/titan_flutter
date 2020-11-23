import 'package:json_annotation/json_annotation.dart';

part 'reward_history_entity.g.dart';


@JsonSerializable()
class RewardHistoryEntity extends Object {

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'created_at')
  String createdAt;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  @JsonKey(name: 'epoch')
  int epoch;

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'type')
  int type;

  @JsonKey(name: 'total_delegation')
  String totalDelegation;

  @JsonKey(name: 'total_delegation_by_operator')
  String totalDelegationByOperator;

  @JsonKey(name: 'total_reward')
  String totalReward;

  @JsonKey(name: 'day_annualization')
  String dayAnnualization;

  @JsonKey(name: 'seven_day_annualization')
  String sevenDayAnnualization;

  @JsonKey(name: 'thirty_day_annualization')
  String thirtyDayAnnualization;

  RewardHistoryEntity(this.id,this.createdAt,this.updatedAt,this.epoch,this.address,this.type,this.totalDelegation,this.totalDelegationByOperator,this.totalReward,this.dayAnnualization,this.sevenDayAnnualization,this.thirtyDayAnnualization,);

  factory RewardHistoryEntity.fromJson(Map<String, dynamic> srcJson) => _$RewardHistoryEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RewardHistoryEntityToJson(this);

}


