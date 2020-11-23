import 'package:json_annotation/json_annotation.dart';

part 'map3_user_entity.g.dart';


@JsonSerializable()
class Map3UserEntity extends Object {

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'creator')
  int creator;

  @JsonKey(name: 'map3_address')
  String map3Address;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'pic')
  String pic;

  @JsonKey(name: 'staking')
  String staking;

  Map3UserEntity(this.address,this.creator,this.map3Address,this.name,this.pic,this.staking,);

  factory Map3UserEntity.fromJson(Map<String, dynamic> srcJson) => _$Map3UserEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$Map3UserEntityToJson(this);

}


