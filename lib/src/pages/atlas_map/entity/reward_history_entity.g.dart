// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_history_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RewardHistoryEntity _$RewardHistoryEntityFromJson(Map<String, dynamic> json) {
  return RewardHistoryEntity(
    json['id'] as int,
    json['created_at'] as String,
    json['updated_at'] as String,
    json['epoch'] as int,
    json['address'] as String,
    json['type'] as int,
    json['total_delegation'] as String,
    json['total_delegation_by_operator'] as String,
    json['total_reward'] as String,
    json['day_annualization'] as String,
    json['seven_day_annualization'] as String,
    json['thirty_day_annualization'] as String,
  );
}

Map<String, dynamic> _$RewardHistoryEntityToJson(
        RewardHistoryEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'epoch': instance.epoch,
      'address': instance.address,
      'type': instance.type,
      'total_delegation': instance.totalDelegation,
      'total_delegation_by_operator': instance.totalDelegationByOperator,
      'total_reward': instance.totalReward,
      'day_annualization': instance.dayAnnualization,
      'seven_day_annualization': instance.sevenDayAnnualization,
      'thirty_day_annualization': instance.thirtyDayAnnualization,
    };
