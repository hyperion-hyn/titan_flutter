import 'package:json_annotation/json_annotation.dart';

part 'transaction_info_vo.g.dart';

@JsonSerializable()
class TransactionInfoVo extends Object {
  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'chain')
  String chain;

  @JsonKey(name: 'hash')
  String hash;

  @JsonKey(name: 'symbol')
  String symbol;

  @JsonKey(name: 'fromAddress')
  String fromAddress;

  @JsonKey(name: 'toAddress')
  String toAddress;

  @JsonKey(name: 'amount')
  String amount;

  @JsonKey(name: 'time')
  int time;

  @JsonKey(name: 'status')
  int status;

  TransactionInfoVo(
    this.id,
    this.chain,
    this.address,
    this.hash,
    this.symbol,
    this.fromAddress,
    this.toAddress,
    this.amount,
    this.time,
    this.status,
  );

  @override
  String toString() {
    return toJson().toString();
  }


  factory TransactionInfoVo.fromJson(Map<String, dynamic> srcJson) =>
      _$TransactionInfoVoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$TransactionInfoVoToJson(this);
}
