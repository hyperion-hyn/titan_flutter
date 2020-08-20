// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'committee_info_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommitteeInfoEntity _$CommitteeInfoEntityFromJson(Map<String, dynamic> json) {
  return CommitteeInfoEntity(
    json['block_num'] as int,
    json['candidate'] as int,
    json['elected'] as int,
    json['end_time'] as String,
    json['epoch'] as int,
    json['start_time'] as String,
  );
}

Map<String, dynamic> _$CommitteeInfoEntityToJson(
        CommitteeInfoEntity instance) =>
    <String, dynamic>{
      'block_num': instance.blockNum,
      'candidate': instance.candidate,
      'elected': instance.elected,
      'end_time': instance.endTime,
      'epoch': instance.epoch,
      'start_time': instance.startTime,
    };
