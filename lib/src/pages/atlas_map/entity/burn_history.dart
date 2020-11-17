import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/utils/format_util.dart';

part 'burn_history.g.dart';

@JsonSerializable()
class BurnHistory extends Object {
  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'created_at')
  String createdAt;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  @JsonKey(name: 'hash')
  String hash;

  @JsonKey(name: 'foundation')
  String foundation;

  @JsonKey(name: 'epoch')
  int epoch;

  @JsonKey(name: 'block')
  int block;

  @JsonKey(name: 'internal_amount')
  String internalAmount;

  @JsonKey(name: 'external_amount')
  String externalAmount;

  @JsonKey(name: 'total_amount')
  String totalAmount;

  @JsonKey(name: 'timestamp')
  int timestamp;

  @JsonKey(name: 'burn_rate')
  String burnRate;

  @JsonKey(name: 'hyn_supply')
  String hynSupply;

  @JsonKey(name: 'type')
  int type;

  String getTotalAmount() {
    return FormatUtil.weiToEtherStr(totalAmount);
  }

  BurnHistory(
    this.id,
    this.createdAt,
    this.updatedAt,
    this.hash,
    this.foundation,
    this.epoch,
    this.block,
    this.internalAmount,
    this.externalAmount,
    this.totalAmount,
    this.timestamp,
    this.burnRate,
    this.hynSupply,
    this.type,
  );

  factory BurnHistory.fromJson(Map<String, dynamic> srcJson) =>
      _$BurnHistoryFromJson(srcJson);

  Map<String, dynamic> toJson() => _$BurnHistoryToJson(this);
}

@JsonSerializable()
class BurnMsg extends Object {
  @JsonKey(name: 'actualAmount')
  String actualAmount;

  @JsonKey(name: 'latest')
  BurnHistory latestBurnHistory;

  BurnMsg(
    this.actualAmount,
    this.latestBurnHistory,
  );

  factory BurnMsg.fromJson(Map<String, dynamic> srcJson) =>
      _$BurnMsgFromJson(srcJson);

  Map<String, dynamic> toJson() => _$BurnMsgToJson(this);
}
