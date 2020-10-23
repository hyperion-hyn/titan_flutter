// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'committee_info_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommitteeInfoEntity _$CommitteeInfoEntityFromJson(Map<String, dynamic> json) {
  return CommitteeInfoEntity(
    json['block_height'] as int,
    json['block_num'] as int,
    json['block_num_start'] as int,
    json['candidate'] as int,
    json['elected'] as int,
    json['epoch'] as int,
    json['sec_per_block'] as int,
  );
}

Map<String, dynamic> _$CommitteeInfoEntityToJson(CommitteeInfoEntity instance) =>
    <String, dynamic>{
      'block_height': instance.blockHeight,
      'block_num': instance.blockNum,
      'block_num_start': instance.blockNumStart,
      'candidate': instance.candidate,
      'elected': instance.elected,
      'epoch': instance.epoch,
      'sec_per_block': instance.secPerBlock,
    };
