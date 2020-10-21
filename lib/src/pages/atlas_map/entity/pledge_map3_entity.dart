import 'package:json_annotation/json_annotation.dart';

part 'pledge_map3_entity.g.dart';


@JsonSerializable()
class PledgeMap3Entity extends Object {

  @JsonKey(name: 'payload')
  Payload payload;

  @JsonKey(name: 'raw_tx')
  String rawTx;

  PledgeMap3Entity({this.payload,this.rawTx,});



  factory PledgeMap3Entity.fromJson(Map<String, dynamic> srcJson) => _$PledgeMap3EntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$PledgeMap3EntityToJson(this);

}


@JsonSerializable()
class Payload extends Object {

  @JsonKey(name: 'user_email')
  String userEmail;

  @JsonKey(name: 'user_identity')
  String userIdentity;

  @JsonKey(name: 'user_name')
  String userName;

  @JsonKey(name: 'user_pic')
  String userPic;

  Payload({this.userEmail,this.userIdentity,this.userName,this.userPic,});

  factory Payload.fromJson(Map<String, dynamic> srcJson) => _$PayloadFromJson(srcJson);

  Map<String, dynamic> toJson() => _$PayloadToJson(this);

}


