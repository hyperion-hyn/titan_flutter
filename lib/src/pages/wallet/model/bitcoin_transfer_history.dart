import 'package:json_annotation/json_annotation.dart';

part 'bitcoin_transfer_history.g.dart';


@JsonSerializable()
class BitcoinTransferHistory extends Object {

  @JsonKey(name: 'from_addr')
  String fromAddr;

  @JsonKey(name: 'to_addr')
  String toAddr;

  @JsonKey(name: 'n_confirmed')
  int nConfirmed;

  @JsonKey(name: 'confirm_at')
  int confirmAt;

  @JsonKey(name: 'amount')
  int amount;

  @JsonKey(name: 'fee')
  int fee;

  @JsonKey(name: 'tx_hash')
  String txHash;

  @JsonKey(name: 'third_addr')
  String thirdAddr;

  BitcoinTransferHistory(this.fromAddr,this.toAddr,this.nConfirmed,this.confirmAt,this.amount,this.fee,this.txHash,this.thirdAddr,);

  factory BitcoinTransferHistory.fromJson(Map<String, dynamic> srcJson) => _$BitcoinTransferHistoryFromJson(srcJson);

  Map<String, dynamic> toJson() => _$BitcoinTransferHistoryToJson(this);

}