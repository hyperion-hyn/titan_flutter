import 'package:json_annotation/json_annotation.dart'; 
  
part 'rp_miners_entity.g.dart';


@JsonSerializable()
  class RpMinersEntity extends Object {

  @JsonKey(name: 'inviter')
  RpMinerInfo inviter;

  @JsonKey(name: 'miners')
  List<RpMinerInfo> miners;

  RpMinersEntity(this.inviter,this.miners,);

  factory RpMinersEntity.fromJson(Map<String, dynamic> srcJson) => _$RpMinersEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpMinersEntityToJson(this);

}

 

  
@JsonSerializable()
  class RpMinerInfo extends Object {

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'avatar')
  String avatar;

  @JsonKey(name: 'inviteTime')
  int inviteTime;

  @JsonKey(name: 'level')
  int level;

  @JsonKey(name: 'name')
  String name;

  RpMinerInfo(this.address,this.avatar,this.inviteTime,this.level,this.name,);

  factory RpMinerInfo.fromJson(Map<String, dynamic> srcJson) => _$RpMinerInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpMinerInfoToJson(this);

}

  
