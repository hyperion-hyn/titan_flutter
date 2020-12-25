import 'package:json_annotation/json_annotation.dart'; 
  
part 'account_bind_info_entity.g.dart';


/*

{
  "code": 0,
  "msg": "success",
  "data":
  {
    "applyCount": 0,
    "isMaster": true,
    "isSub": false,
    "master": "moyaying@163.com",
    "request": {
      "id": 1,
      "userID": 15,
      "email": "moyaying@163.com",
      "state": 1,
      "requestTime": 1605596455
    },
    "sub": "test3@lalala.ooo",
    "subRelationships": [
      {
        "userID": 15,
        "email": "test3@lalala.ooo",
        "bindTime": 1605596455
      }
    ]
  }
}
*/
@JsonSerializable()
  class AccountBindInfoEntity extends Object {

  @JsonKey(name: 'applyCount')
  int applyCount;

  @JsonKey(name: 'isMaster')
  bool isMaster;

  @JsonKey(name: 'isSub')
  bool isSub;

  @JsonKey(name: 'master')
  String master;

  @JsonKey(name: 'request')
  Request request;

  @JsonKey(name: 'sub')
  String sub;

  @JsonKey(name: 'subRelationships')
  List<SubRelationships> subRelationships;

  AccountBindInfoEntity(this.applyCount,this.isMaster,this.isSub,this.master,this.request,this.sub,this.subRelationships,);

  factory AccountBindInfoEntity.fromJson(Map<String, dynamic> srcJson) => _$AccountBindInfoEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AccountBindInfoEntityToJson(this);

}

  
@JsonSerializable()
  class Request extends Object {

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'userID')
  int userID;

  @JsonKey(name: 'email')
  String email;

  @JsonKey(name: 'state')
  int state;

  @JsonKey(name: 'requestTime')
  int requestTime;

  Request(this.id,this.userID,this.email,this.state,this.requestTime,);

  factory Request.fromJson(Map<String, dynamic> srcJson) => _$RequestFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RequestToJson(this);

}

  
@JsonSerializable()
  class SubRelationships extends Object {

  @JsonKey(name: 'userID')
  int userID;

  @JsonKey(name: 'email')
  String email;

  @JsonKey(name: 'bindTime')
  int bindTime;

  SubRelationships(this.userID,this.email,this.bindTime,);

  factory SubRelationships.fromJson(Map<String, dynamic> srcJson) => _$SubRelationshipsFromJson(srcJson);

  Map<String, dynamic> toJson() => _$SubRelationshipsToJson(this);

}

  
