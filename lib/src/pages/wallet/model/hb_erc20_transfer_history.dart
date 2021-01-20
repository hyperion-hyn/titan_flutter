import 'package:json_annotation/json_annotation.dart';

part 'hb_erc20_transfer_history.g.dart';

@JsonSerializable()
class HbErc20TransferHistory {
  String blockNumber;
  String timeStamp;
  String hash;
  String nonce;
  String blockHash;
  String from;
  String contractAddress;
  String to;
  String value;
  String tokenName;
  String tokenSymbol;
  String tokenDecimal;
  String transactionIndex;
  String gas;
  String gasPrice;
  String gasUsed;
  String cumulativeGasUsed;
  String input;
  String confirmations;
  String txReceiptStatus;

  HbErc20TransferHistory(
      this.blockNumber,
      this.timeStamp,
      this.hash,
      this.nonce,
      this.blockHash,
      this.from,
      this.contractAddress,
      this.to,
      this.value,
      this.tokenName,
      this.tokenSymbol,
      this.tokenDecimal,
      this.transactionIndex,
      this.gas,
      this.gasPrice,
      this.gasUsed,
      this.cumulativeGasUsed,
      this.input,
      this.confirmations,
      this.txReceiptStatus,
      );

  factory HbErc20TransferHistory.fromJson(Map<String, dynamic> json) => _$HbErc20TransferHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$HbErc20TransferHistoryToJson(this);
}
