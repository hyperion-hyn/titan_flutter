import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/utils/format_util.dart';

part 'rp_airdrop_round_info.g.dart';

@JsonSerializable()
class RpAirdropRoundInfo extends Object {
  @JsonKey(name: 'start_time')
  int startTime;

  @JsonKey(name: 'end_time')
  int endTime;

  @JsonKey(name: 'my_rp_count')
  int myRpCount;

  @JsonKey(name: 'my_rp_amount')
  String myRpAmount;

  @JsonKey(name: 'total_rp_amount')
  String totalRpAmount;

  @JsonKey(name: 'current_time')
  int currentTime;

  String get myRpAmountStr => FormatUtil.weiToEtherStr(myRpAmount) ?? '--';

  String get totalRpAmountStr => FormatUtil.weiToEtherStr(totalRpAmount) ?? '0';

  RpAirdropRoundInfo(
    this.startTime,
    this.endTime,
    this.myRpCount,
    this.myRpAmount,
    this.totalRpAmount,
    this.currentTime,
  );

  factory RpAirdropRoundInfo.fromJson(Map<String, dynamic> srcJson) => _$RpAirdropRoundInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpAirdropRoundInfoToJson(this);
}
