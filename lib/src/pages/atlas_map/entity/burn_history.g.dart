// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'burn_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BurnHistory _$BurnHistoryFromJson(Map<String, dynamic> json) {
  return BurnHistory(
    json['actualAmount'] as String,
    json['created_at'] as String,
    json['epoch'] as int,
    json['estimateAmount'] as String,
    json['id'] as int,
    json['status'] as int,
    json['timestamp'] as int,
    json['tx_hash'] as String,
    json['updated_at'] as String,
  );
}

Map<String, dynamic> _$BurnHistoryToJson(BurnHistory instance) =>
    <String, dynamic>{
      'actualAmount': instance.actualAmount,
      'created_at': instance.createdAt,
      'epoch': instance.epoch,
      'estimateAmount': instance.estimateAmount,
      'id': instance.id,
      'status': instance.status,
      'timestamp': instance.timestamp,
      'tx_hash': instance.txHash,
      'updated_at': instance.updatedAt,
    };

BurnMsg _$BurnMsgFromJson(Map<String, dynamic> json) {
  return BurnMsg(
    json['actualAmount'] as String,
    json['latest'] == null
        ? null
        : BurnHistory.fromJson(json['latest'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$BurnMsgToJson(BurnMsg instance) =>
    <String, dynamic>{
      'actualAmount': instance.actualAmount,
      'latest': instance.latestBurnHistory,
    };
