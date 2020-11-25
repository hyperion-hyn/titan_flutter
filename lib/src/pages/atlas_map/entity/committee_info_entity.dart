import 'package:json_annotation/json_annotation.dart';

part 'committee_info_entity.g.dart';

/*
*
block_height	integer
每个纪元包含多少个块

block_num	integer
当前块高

block_num_start	integer
当前纪元的起始块高

candidate	integer
候选节点数量

elected	integer
当选节点数量

epoch	integer
当前纪元

sec_per_block	integer
每隔多少秒出一个块
* 
* */

@JsonSerializable()
class CommitteeInfoEntity extends Object {
  @JsonKey(name: 'block_height')
  int blockHeight;

  @JsonKey(name: 'block_num')
  int blockNum;

  @JsonKey(name: 'block_num_start')
  int blockNumStart;

  @JsonKey(name: 'candidate')
  int candidate;

  @JsonKey(name: 'elected')
  int elected;

  @JsonKey(name: 'epoch')
  int epoch;

  @JsonKey(name: 'sec_per_block')
  int secPerBlock;

  CommitteeInfoEntity(
    this.blockHeight,
    this.blockNum,
    this.blockNumStart,
    this.candidate,
    this.elected,
    this.epoch,
    this.secPerBlock,
  );

  factory CommitteeInfoEntity.fromJson(Map<String, dynamic> srcJson) =>
      _$CommitteeInfoEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CommitteeInfoEntityToJson(this);
}
