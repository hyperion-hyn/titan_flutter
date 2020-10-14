import 'package:json_annotation/json_annotation.dart';
import 'dart:convert' as jsonUtils;

part 'transtion_detail_vo.g.dart';

@JsonSerializable()
class TransactionDetailVo {
  int id;
  String contractAddress;
  int localTransferType;

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

  String data;
  Map dataDecoded;
  String blockHash;
  int blockNum;
  int epoch;
  int transactionIndex;
  int hynType;

  TransactionDetailVo({
    this.id,
    this.contractAddress,
    this.localTransferType,
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
    this.data,
    this.dataDecoded,
    this.blockHash,
    this.blockNum,
    this.epoch,
    this.transactionIndex,
    this.hynType,
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