import 'package:json_annotation/json_annotation.dart'; 
  
part 'rp_detail_entity.g.dart';


@JsonSerializable()
  class RpDetailEntity extends Object {

  @JsonKey(name: 'level_intro')
  LevelIntro levelIntro;

  @JsonKey(name: 'lucky_intro')
  LuckyIntro luckyIntro;

  @JsonKey(name: 'promotion_intro')
  PromotionIntro promotionIntro;

  @JsonKey(name: 'records')
  List<Records> records;

  @JsonKey(name: 'red_pocket')
  RedPocket redPocket;

  RpDetailEntity(this.levelIntro,this.luckyIntro,this.promotionIntro,this.records,this.redPocket,);

  factory RpDetailEntity.fromJson(Map<String, dynamic> srcJson) => _$RpDetailEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpDetailEntityToJson(this);

}

  
@JsonSerializable()
  class LevelIntro extends Object {

  @JsonKey(name: 'level')
  int level;

  @JsonKey(name: 'other_user_amount')
  int otherUserAmount;

  @JsonKey(name: 'other_user_count')
  int otherUserCount;

  LevelIntro(this.level,this.otherUserAmount,this.otherUserCount,);

  factory LevelIntro.fromJson(Map<String, dynamic> srcJson) => _$LevelIntroFromJson(srcJson);

  Map<String, dynamic> toJson() => _$LevelIntroToJson(this);

}

  
@JsonSerializable()
  class LuckyIntro extends Object {

  @JsonKey(name: 'amount')
  int amount;

  @JsonKey(name: 'luck')
  int luck;

  LuckyIntro(this.amount,this.luck,);

  factory LuckyIntro.fromJson(Map<String, dynamic> srcJson) => _$LuckyIntroFromJson(srcJson);

  Map<String, dynamic> toJson() => _$LuckyIntroToJson(this);

}

  
@JsonSerializable()
  class PromotionIntro extends Object {

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'from')
  int from;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'to')
  int to;

  PromotionIntro(this.address,this.from,this.name,this.to,);

  factory PromotionIntro.fromJson(Map<String, dynamic> srcJson) => _$PromotionIntroFromJson(srcJson);

  Map<String, dynamic> toJson() => _$PromotionIntroToJson(this);

}

  
@JsonSerializable()
  class Records extends Object {

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'amount')
  int amount;

  @JsonKey(name: 'level')
  int level;

  @JsonKey(name: 'luck')
  int luck;

  @JsonKey(name: 'name')
  String name;

  Records(this.address,this.amount,this.level,this.luck,this.name,);

  factory Records.fromJson(Map<String, dynamic> srcJson) => _$RecordsFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RecordsToJson(this);

}

  
@JsonSerializable()
  class RedPocket extends Object {

  @JsonKey(name: 'amount')
  int amount;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'luck')
  int luck;

  @JsonKey(name: 'time')
  String time;

  @JsonKey(name: 'total_amount')
  int totalAmount;

  @JsonKey(name: 'type')
  int type;

  RedPocket(this.amount,this.id,this.luck,this.time,this.totalAmount,this.type,);

  factory RedPocket.fromJson(Map<String, dynamic> srcJson) => _$RedPocketFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RedPocketToJson(this);

}

  
