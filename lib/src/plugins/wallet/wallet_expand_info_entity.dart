import 'package:json_annotation/json_annotation.dart';

part 'wallet_expand_info_entity.g.dart';


@JsonSerializable()
class WalletExpandInfoEntity extends Object {

  @JsonKey(name: 'localHeadImg')
  String localHeadImg;

  @JsonKey(name: 'netHeadImg')
  String netHeadImg;

  @JsonKey(name: 'pswRemind')
  String pswRemind;

  WalletExpandInfoEntity(this.localHeadImg,this.netHeadImg,this.pswRemind,);

  WalletExpandInfoEntity.defaultEntity();

  factory WalletExpandInfoEntity.fromJson(Map<String, dynamic> srcJson) => _$WalletExpandInfoEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$WalletExpandInfoEntityToJson(this);

}