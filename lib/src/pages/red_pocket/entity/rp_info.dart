import 'package:json_annotation/json_annotation.dart';

part 'rp_info.g.dart';


@JsonSerializable()
class RPInfo extends Object {

  @JsonKey(name: 'level')
  String level;

  @JsonKey(name: 'balance')
  String balance;

  @JsonKey(name: 'rp_balance')
  String rpBalance;

  @JsonKey(name: 'rp_today')
  String rpToday;

  @JsonKey(name: 'rp_yesterday')
  String rpYesterday;

  @JsonKey(name: 'rp_missed')
  String rpMissed;

  RPInfo(this.level,this.balance,this.rpBalance,this.rpToday,this.rpYesterday,this.rpMissed,);

  factory RPInfo.fromJson(Map<String, dynamic> srcJson) => _$RPInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RPInfoToJson(this);

}


