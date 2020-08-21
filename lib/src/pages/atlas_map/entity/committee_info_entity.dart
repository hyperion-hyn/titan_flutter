import 'package:json_annotation/json_annotation.dart'; 
  
part 'committee_info_entity.g.dart';


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

  
