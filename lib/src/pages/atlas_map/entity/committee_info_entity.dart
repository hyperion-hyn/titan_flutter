import 'package:json_annotation/json_annotation.dart'; 
  
part 'committee_info_entity.g.dart';

/*
{
block_num	integer
当前块高

candidate	integer
候选节点数量

elected	integer
当选节点数量

end_time	string
纪元结束日期

epoch	integer
当前纪元

start_time	string
纪元开始日期

}*/
@JsonSerializable()
  class CommitteeInfoEntity extends Object {

  @JsonKey(name: 'block_num')
  int blockNum;

  @JsonKey(name: 'candidate')
  int candidate;

  @JsonKey(name: 'elected')
  int elected;

  @JsonKey(name: 'end_time')
  String endTime;

  @JsonKey(name: 'epoch')
  int epoch;

  @JsonKey(name: 'start_time')
  String startTime;

  CommitteeInfoEntity(this.blockNum,this.candidate,this.elected,this.endTime,this.epoch,this.startTime,);

  factory CommitteeInfoEntity.fromJson(Map<String, dynamic> srcJson) => _$CommitteeInfoEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CommitteeInfoEntityToJson(this);

}

  
