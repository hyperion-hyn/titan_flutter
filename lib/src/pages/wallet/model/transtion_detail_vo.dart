import 'package:json_annotation/json_annotation.dart';

part 'transtion_detail_vo.g.dart';

@JsonSerializable()
class TransactionDetailVo {
  int id;
  int type; //1、转出 2、转入
  int state; //1 success, 0 pending, -1 failed
  String gasUsed;
  String symbol;

  String hash;
  double amount;
  String fromAddress;
  String toAddress;
  int time;
  String nonce;
  String gas;
  String gasPrice;
  String describe;
  String contractAddress;
  int localTransferType; //1、eth 2、hyn and usdt
  String password;

  TransactionDetailVo({
    this.id,
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
    this.contractAddress,
    this.localTransferType,
    this.password,
  });

  factory TransactionDetailVo.fromJson(Map<String, dynamic> json) => _$TransactionDetailVoFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionDetailVoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

class LocalTransferType {
  static const LOCAL_TRANSFER_ETH = 1;
  static const LOCAL_TRANSFER_HYN_USDT = 2;
  static const LOCAL_TRANSFER_MAP3 = 3;
}