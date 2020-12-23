import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/utils/format_util.dart';

part 'rp_level_airdrop_info.g.dart';

@JsonSerializable()
class RpLevelAirdropInfo extends Object {
  @JsonKey(name: 'total_amount')
  String totalAmount;

  @JsonKey(name: 'per_level_amount')
  Per_level_amount perLevelAmount;

  RpLevelAirdropInfo(
    this.totalAmount,
    this.perLevelAmount,
  );

  String get totalRpAmountStr => FormatUtil.weiToEtherStr(totalAmount) ?? '0';

  String getLevelAmountStr(int level) {
    try {
      var amount;
      if (level == 1) {
        amount = FormatUtil.weiToEtherStr(perLevelAmount?.level1);
      } else if (level == 2) {
        amount = FormatUtil.weiToEtherStr(perLevelAmount?.level2);
      } else if (level == 3) {
        amount = FormatUtil.weiToEtherStr(perLevelAmount?.level3);
      } else if (level == 4) {
        amount = FormatUtil.weiToEtherStr(perLevelAmount?.level4);
      } else if (level == 5) {
        amount = FormatUtil.weiToEtherStr(perLevelAmount?.level5);
      }
      var result = FormatUtil.stringFormatCoinNum(
        amount,
        decimal: 4,
      );
      return result;
    } catch (e) {
      return '--';
    }
  }

  factory RpLevelAirdropInfo.fromJson(Map<String, dynamic> srcJson) =>
      _$RpLevelAirdropInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpLevelAirdropInfoToJson(this);
}

@JsonSerializable()
class Per_level_amount extends Object {
  @JsonKey(name: '1')
  String level1;

  @JsonKey(name: '2')
  String level2;

  @JsonKey(name: '3')
  String level3;

  @JsonKey(name: '4')
  String level4;

  @JsonKey(name: '5')
  String level5;

  Per_level_amount(
    this.level1,
    this.level2,
    this.level3,
    this.level4,
    this.level5,
  );

  factory Per_level_amount.fromJson(Map<String, dynamic> srcJson) =>
      _$Per_level_amountFromJson(srcJson);

  Map<String, dynamic> toJson() => _$Per_level_amountToJson(this);
}
