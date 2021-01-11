import 'package:json_annotation/json_annotation.dart'; 
  
part 'rp_share_entity.g.dart';


@JsonSerializable()
  class RpShareEntity extends Object {

  @JsonKey(name: 'details')
  List<RpShareDetailEntity> details;

  @JsonKey(name: 'info')
  RpShareInfoEntity info;

  RpShareEntity(this.details,this.info,);

  factory RpShareEntity.fromJson(Map<String, dynamic> srcJson) => _$RpShareEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpShareEntityToJson(this);

}

  
@JsonSerializable()
  class RpShareDetailEntity extends Object {

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'avatar')
  String avatar;

  @JsonKey(name: 'hynAmount')
  String hynAmount;

  @JsonKey(name: 'isBest')
  bool isBest;

  @JsonKey(name: 'rpAmount')
  String rpAmount;

  @JsonKey(name: 'username')
  String username;

  RpShareDetailEntity(this.address,this.avatar,this.hynAmount,this.isBest,this.rpAmount,this.username,);

  factory RpShareDetailEntity.fromJson(Map<String, dynamic> srcJson) => _$RpShareDetailEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpShareDetailEntityToJson(this);

}

  
@JsonSerializable()
  class RpShareInfoEntity extends Object {

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'alreadyGot')
  bool alreadyGot;

  @JsonKey(name: 'avatar')
  String avatar;

  @JsonKey(name: 'coordinates')
  List<double> coordinates;

  @JsonKey(name: 'createdAt')
  int createdAt;

  @JsonKey(name: 'greeting')
  String greeting;

  @JsonKey(name: 'hasPWD')
  bool hasPWD;

  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'isNewBee')
  bool isNewBee;

  @JsonKey(name: 'owner')
  String owner;

  @JsonKey(name: 'range')
  int range;

  @JsonKey(name: 'rpType')
  String rpType;

  @JsonKey(name: 'state')
  String state;

  @JsonKey(name: 'userIsNewBee')
  bool userIsNewBee;

  RpShareInfoEntity(this.address,this.alreadyGot,this.avatar,this.coordinates,this.createdAt,this.greeting,this.hasPWD,this.id,this.isNewBee,this.owner,this.range,this.rpType,this.state,this.userIsNewBee,);

  factory RpShareInfoEntity.fromJson(Map<String, dynamic> srcJson) => _$RpShareInfoEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpShareInfoEntityToJson(this);

}

  
