import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/utils/format_util.dart';

part 'rp_my_rp_record_entity.g.dart';

@JsonSerializable()
class RpMyRpRecordEntity extends Object {
  @JsonKey(name: 'data')
  List<RpOpenRecordEntity> data;

  @JsonKey(name: 'paging_key')
  Map<String,dynamic> pagingKey;

  RpMyRpRecordEntity(
    this.data,
    this.pagingKey,
  );

  factory RpMyRpRecordEntity.fromJson(Map<String, dynamic> srcJson) => _$RpMyRpRecordEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpMyRpRecordEntityToJson(this);
}

@JsonSerializable()
class RpMyRpSplitRecordEntity extends Object {
  @JsonKey(name: 'data')
  List<RpOpenRecordEntity> data;

  @JsonKey(name: 'paging_key')
  Map<String,dynamic> pagingKey;

  RpMyRpSplitRecordEntity(
    this.data,
    this.pagingKey,
  );

  factory RpMyRpSplitRecordEntity.fromJson(Map<String, dynamic> srcJson) => _$RpMyRpSplitRecordEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpMyRpSplitRecordEntityToJson(this);
}

@JsonSerializable()
class RpOpenRecordEntity extends Object {
  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'amount')
  String amount;

  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'luck')
  int luck;

  @JsonKey(name: 'red_pocket_id')
  int redPocketId;

  @JsonKey(name: 'created_at')
  int createdAt;

  @JsonKey(name: 'total_amount')
  String totalAmount;

  @JsonKey(name: 'type')
  int type;

  @JsonKey(name: 'username')
  String username;

  @JsonKey(name: 'from')
  int from;

  @JsonKey(name: 'to')
  int to;

  @JsonKey(name: 'other_user_count')
  int otherUserCount;

  @JsonKey(name: 'other_user_amount')
  String otherUserAmount;

  @JsonKey(name: 'role')
  int role;

  @JsonKey(name: 'level')
  int level;

  @JsonKey(name: 'tx_hash')
  String txHash;


  String get otherUserAmountStr => FormatUtil.weiToEtherStr(otherUserAmount) ?? '0';

  String get totalAmountStr => FormatUtil.weiToEtherStr(totalAmount) ?? '0';

  String get amountStr => FormatUtil.weiToEtherStr(amount) ?? '0';

  RpOpenRecordEntity(
    this.address,
    this.amount,
    this.id,
    this.luck,
    this.redPocketId,
    this.createdAt,
    this.totalAmount,
    this.type,
    this.username,
    this.from,
    this.to,
    this.otherUserCount,
    this.otherUserAmount,
    this.role,
    this.level,
    this.txHash,
  );

  RpOpenRecordEntity.onlyType(this.type);

  factory RpOpenRecordEntity.fromJson(Map<String, dynamic> srcJson) => _$RpOpenRecordEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpOpenRecordEntityToJson(this);
}
