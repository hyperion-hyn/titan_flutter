import 'package:json_annotation/json_annotation.dart'; 
  
part 'rp_my_level_info.g.dart';


@JsonSerializable()
  class RpMyLevelInfo extends Object {

  @JsonKey(name: 'current_holding')
  int currentHolding;

  @JsonKey(name: 'current_level')
  int currentLevel;

  RpMyLevelInfo(this.currentHolding,this.currentLevel,);

  factory RpMyLevelInfo.fromJson(Map<String, dynamic> srcJson) => _$RpMyLevelInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpMyLevelInfoToJson(this);

}

  
