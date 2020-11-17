// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'burn_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BurnHistory _$BurnHistoryFromJson(Map<String, dynamic> json) {
  return BurnHistory(
    json['id'] as int,
    json['created_at'] as String,
    json['updated_at'] as String,
    json['hash'] as String,
    json['foundation'] as String,
    json['epoch'] as int,
    json['block'] as int,
    json['internal_amount'] as String,
    json['external_amount'] as String,
    json['total_amount'] as String,
    json['timestamp'] as int,
    json['burn_rate'] as String,
    json['hyn_supply'] as String,
    json['type'] as int,
  );
}


Map<String, dynamic> _$BurnHistoryToJson(BurnHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'hash': instance.hash,
      'foundation': instance.foundation,
      'epoch': instance.epoch,
      'block': instance.block,
      'internal_amount': instance.internalAmount,
      'external_amount': instance.externalAmount,
      'total_amount': instance.totalAmount,
      'timestamp': instance.timestamp,
      'burn_rate': instance.burnRate,
      'hyn_supply': instance.hynSupply,
      'type': instance.type,
    };

BurnMsg _$BurnMsgFromJson(Map<String, dynamic> json) {
  return BurnMsg(
    json['actualAmount'] as String,
    json['latest'] == null
        ? null
        : BurnHistory.fromJson(json['latest'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$BurnMsgToJson(BurnMsg instance) => <String, dynamic>{
      'actualAmount': instance.actualAmount,
      'latest': instance.latestBurnHistory,
    };
