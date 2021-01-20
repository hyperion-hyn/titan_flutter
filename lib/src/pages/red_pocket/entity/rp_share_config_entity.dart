import 'package:json_annotation/json_annotation.dart'; 
  
part 'rp_share_config_entity.g.dart';


@JsonSerializable()
  class RpShareConfigEntity extends Object {

  @JsonKey(name: 'hynMin')
  String hynMin;

  @JsonKey(name: 'receiveAddr')
  String receiveAddr;

  @JsonKey(name: 'rpMin')
  String rpMin;

  RpShareConfigEntity(this.hynMin,this.receiveAddr,this.rpMin,);

  factory RpShareConfigEntity.fromJson(Map<String, dynamic> srcJson) => _$RpShareConfigEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpShareConfigEntityToJson(this);

}

  
