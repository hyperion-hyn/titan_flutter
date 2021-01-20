import 'package:json_annotation/json_annotation.dart';

part 'ht_transfer_history.g.dart';

@JsonSerializable()
class HtTransferHistory {
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
  String txReceiptStatus;
  String input;
  String contractAddress;
  String cumulativeGasUsed;
  String gasUsed;
  String confirmations;

  HtTransferHistory(
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
      this.txReceiptStatus,
      this.input,
      this.contractAddress,
      this.cumulativeGasUsed,
      this.gasUsed,
      this.confirmations);

  factory HtTransferHistory.fromJson(Map<String, dynamic> json) => _$HtTransferHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$HtTransferHistoryToJson(this);
}
