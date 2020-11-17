import 'package:json_annotation/json_annotation.dart';

part 'burn_history.g.dart';

@JsonSerializable()
class BurnHistory extends Object {
  @JsonKey(name: 'actualAmount')
  String actualAmount;

  @JsonKey(name: 'created_at')
  String createdAt;

  @JsonKey(name: 'epoch')
  int epoch;

  @JsonKey(name: 'estimateAmount')
  String estimateAmount;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'status')
  int status;

  @JsonKey(name: 'timestamp')
  int timestamp;

  @JsonKey(name: 'tx_hash')
  String txHash;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  BurnHistory(
    this.actualAmount,
    this.createdAt,
    this.epoch,
    this.estimateAmount,
    this.id,
    this.status,
    this.timestamp,
    this.txHash,
    this.updatedAt,
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
