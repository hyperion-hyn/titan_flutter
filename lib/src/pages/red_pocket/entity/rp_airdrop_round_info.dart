import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/utils/format_util.dart';

part 'rp_airdrop_round_info.g.dart';

@JsonSerializable()
class RpAirdropRoundInfo extends Object {
  @JsonKey(name: 'startTime')
  int startTime;

  @JsonKey(name: 'endTime')
  int endTime;

  @JsonKey(name: 'myRpCount')
  int myRpCount;

  @JsonKey(name: 'myRpAmount')
  String myRpAmount;

  @JsonKey(name: 'totalRpAmount')
  String totalRpAmount;

  String get myRpAmountStr => FormatUtil.weiToEtherStr(myRpAmount) ?? '--';

  String get totalRpAmountStr => FormatUtil.weiToEtherStr(totalRpAmount) ?? '--';


  RpAirdropRoundInfo(
    this.startTime,
    this.endTime,
    this.myRpCount,
    this.myRpAmount,
    this.totalRpAmount,
  );

  factory RpAirdropRoundInfo.fromJson(Map<String, dynamic> srcJson) =>
      _$RpAirdropRoundInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpAirdropRoundInfoToJson(this);
}
