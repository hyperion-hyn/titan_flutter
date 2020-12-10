import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/utils/format_util.dart';

part 'rp_holding_record_entity.g.dart';

@JsonSerializable()
class RPLevelHistory extends Object {
  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'burning')
  String burning;

  @JsonKey(name: 'circulation')
  String circulation;

  @JsonKey(name: 'created_at')
  String createdAt;

  @JsonKey(name: 'from')
  int from;

  @JsonKey(name: 'highest_level')
  int highestLevel;

  @JsonKey(name: 'holding')
  String holding;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'state')
  int state;

  @JsonKey(name: 'to')
  int to;

  @JsonKey(name: 'total_holding')
  String totalHolding;

  @JsonKey(name: 'tx_hash')
  String txHash;

  @JsonKey(name: 'type')
  int type;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  @JsonKey(name: 'withdraw')
  String withdraw;

  String get withdrawStr => FormatUtil.weiToEtherStr(withdraw) ?? '0';

  String get burningStr => FormatUtil.weiToEtherStr(burning) ?? '0';

  String get circulationStr => FormatUtil.weiToEtherStr(circulation) ?? '0';

  String get holdingStr => FormatUtil.weiToEtherStr(holding) ?? '0';

  String get totalHoldingStr => FormatUtil.weiToEtherStr(totalHolding) ?? '0';

  RPLevelHistory(
    this.address,
    this.burning,
    this.circulation,
    this.createdAt,
    this.from,
    this.highestLevel,
    this.holding,
    this.id,
    this.state,
    this.to,
    this.totalHolding,
    this.txHash,
    this.type,
    this.updatedAt,
    this.withdraw,
  );

  factory RPLevelHistory.fromJson(Map<String, dynamic> srcJson) => _$RpHoldingRecordEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpHoldingRecordEntityToJson(this);
}
