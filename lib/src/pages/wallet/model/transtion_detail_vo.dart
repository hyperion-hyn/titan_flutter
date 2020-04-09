import 'package:json_annotation/json_annotation.dart';

part 'transtion_detail_vo.g.dart';

@JsonSerializable()
class TransactionDetailVo {
  int type; //1、转出 2、转入
  String hash;
  int state; //1 success, 0 pending, -1 failed
  double amount;
  String symbol;
  String fromAddress;
  String toAddress;
  int time;
  String nonce;
  String gas;
  String gasPrice;
  String gasUsed;
  String describe;

  TransactionDetailVo({
    this.type,
    this.state,
    this.amount,
    this.symbol,
    this.fromAddress,
    this.toAddress,
    this.time,
    this.hash,
    this.nonce,
    this.gas,
    this.gasPrice,
    this.gasUsed,
    this.describe,
  });

  factory TransactionDetailVo.fromJson(Map<String, dynamic> json) => _$TransactionDetailVoFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionDetailVoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
