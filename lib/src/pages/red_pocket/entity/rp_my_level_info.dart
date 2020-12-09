import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/utils/format_util.dart';
  
part 'rp_my_level_info.g.dart';


@JsonSerializable()
  class RpMyLevelInfo extends Object {

  @JsonKey(name: 'current_holding')
  String currentHolding;

  @JsonKey(name: 'current_level')
  int currentLevel;

  RpMyLevelInfo(this.currentHolding,this.currentLevel,);

  String get currentHoldingStr => FormatUtil.weiToEtherStr(currentHolding) ?? '0';

  factory RpMyLevelInfo.fromJson(Map<String, dynamic> srcJson) => _$RpMyLevelInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpMyLevelInfoToJson(this);

}

  
