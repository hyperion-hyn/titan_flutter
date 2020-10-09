import 'package:json_annotation/json_annotation.dart';

part 'hyn_transfer_history.g.dart';


@JsonSerializable()
class HynTransferHistory extends Object {

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'createdAt')
  int createdAt;

  @JsonKey(name: 'updatedAt')
  int updatedAt;

  @JsonKey(name: 'tx_hash')
  String txHash;

  @JsonKey(name: 'from')
  String from;

  @JsonKey(name: 'to')
  String to;

  @JsonKey(name: 'nonce')
  int nonce;

  @JsonKey(name: 'value')
  String value;

  @JsonKey(name: 'data')
  String data;

  @JsonKey(name: 'gas_price')
  String gasPrice;

  @JsonKey(name: 'gas_limit')
  int gasLimit;

  @JsonKey(name: 'type')
  int type;

  @JsonKey(name: 'status')
  int status;

  @JsonKey(name: 'gas_used')
  int gasUsed;

  @JsonKey(name: 'block_hash')
  String blockHash;

  @JsonKey(name: 'block_num')
  int blockNum;

  @JsonKey(name: 'epoch')
  int epoch;

  @JsonKey(name: 'timestamp')
  int timestamp;

  @JsonKey(name: 'contract_address')
  String contractAddress;

  @JsonKey(name: 'transaction_index')
  int transactionIndex;

  @JsonKey(name: 'hynUsdPrice')
  int hynUsdPrice;

  @JsonKey(name: 'hynCnyPrice')
  int hynCnyPrice;

  HynTransferHistory(this.id,this.createdAt,this.updatedAt,this.txHash,this.from,this.to,this.nonce,this.value,this.data,this.gasPrice,this.gasLimit,this.type,this.status,this.gasUsed,this.blockHash,this.blockNum,this.epoch,this.timestamp,this.contractAddress,this.transactionIndex,this.hynUsdPrice,this.hynCnyPrice,);

  factory HynTransferHistory.fromJson(Map<String, dynamic> srcJson) => _$HynTransferHistoryFromJson(srcJson);

  Map<String, dynamic> toJson() => _$HynTransferHistoryToJson(this);

}