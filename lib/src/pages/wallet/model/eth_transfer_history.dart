import 'package:json_annotation/json_annotation.dart';

part 'eth_transfer_history.g.dart';

@JsonSerializable()
class EthTransferHistory {
  String blockNumber;
  String timeStamp;
  String hash;
  String nonce;
  String blockHash;
  String transactionIndex;
  String from;
  String to;
  String value;
  String gas;
  String gasPrice;
  String isError;
  @JsonKey(name: "txreceipt_status")
  String txreceiptStatus;
  String input;
  String contractAddress;
  String cumulativeGasUsed;
  String gasUsed;
  String confirmations;

  EthTransferHistory(
      this.blockNumber,
      this.timeStamp,
      this.hash,
      this.nonce,
      this.blockHash,
      this.transactionIndex,
      this.from,
      this.to,
      this.value,
      this.gas,
      this.gasPrice,
      this.isError,
      this.txreceiptStatus,
      this.input,
      this.contractAddress,
      this.cumulativeGasUsed,
      this.gasUsed,
      this.confirmations);

  factory EthTransferHistory.fromJson(Map<String, dynamic> json) => _$EthTransferHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$EthTransferHistoryToJson(this);
}
