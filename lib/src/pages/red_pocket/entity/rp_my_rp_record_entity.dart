import 'package:json_annotation/json_annotation.dart';

part 'rp_my_rp_record_entity.g.dart';

@JsonSerializable()
class RpMyRpRecordEntity extends Object {
  @JsonKey(name: 'data')
  List<RpOpenRecordEntity> data;

  @JsonKey(name: 'paging_key')
  String pagingKey;

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
  String pagingKey;

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

  @JsonKey(name: 'time')
  String time;

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

  RpOpenRecordEntity(
    this.address,
    this.amount,
    this.id,
    this.luck,
    this.redPocketId,
    this.time,
    this.totalAmount,
    this.type,
    this.username,
    this.from,
    this.to,
    this.otherUserCount,
    this.otherUserAmount,
  );

  factory RpOpenRecordEntity.fromJson(Map<String, dynamic> srcJson) => _$RpOpenRecordEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpOpenRecordEntityToJson(this);
}
