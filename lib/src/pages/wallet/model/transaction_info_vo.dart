import 'package:json_annotation/json_annotation.dart';

part 'transaction_info_vo.g.dart';

@JsonSerializable()
class TransactionInfoVo extends Object {
  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'chain')
  String chain;

  @JsonKey(name: 'hash')
  String hash;

  @JsonKey(name: 'symbol')
  String symbol;

  @JsonKey(name: 'from')
  String from;

  @JsonKey(name: 'to')
  String to;

  @JsonKey(name: 'amount')
  int amount;

  @JsonKey(name: 'time')
  int time;

  @JsonKey(name: 'status')
  int status;

  TransactionInfoVo(
    this.id,
    this.chain,
    this.hash,
    this.symbol,
    this.from,
    this.to,
    this.amount,
    this.time,
    this.status,
  );

  factory TransactionInfoVo.fromJson(Map<String, dynamic> srcJson) =>
      _$TransactionInfoVoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$TransactionInfoVoToJson(this);
}
