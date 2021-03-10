import 'package:json_annotation/json_annotation.dart';

part 'cross_chain_record.g.dart';

@JsonSerializable()
class CrossChainRecord extends Object {
  @JsonKey(name: 'symbol')
  String symbol;

  @JsonKey(name: 'sender')
  String sender;

  @JsonKey(name: 'recipient')
  String recipient;

  @JsonKey(name: 'apply_raw_tx')
  String applyRawTx;

  @JsonKey(name: 'atlas_token_address')
  String atlasTokenAddress;

  @JsonKey(name: 'heco_token_address')
  String hecoTokenAddress;

  @JsonKey(name: 'value')
  String value;

  @JsonKey(name: 'atlas_tx')
  String atlasTx;

  @JsonKey(name: 'heco_tx')
  String hecoTx;

  @JsonKey(name: 'type')
  int type;

  @JsonKey(name: 'status')
  int status;

  CrossChainRecord(
    this.symbol,
    this.sender,
    this.recipient,
    this.applyRawTx,
    this.atlasTokenAddress,
    this.hecoTokenAddress,
    this.value,
    this.atlasTx,
    this.hecoTx,
    this.type,
    this.status,
  );

  factory CrossChainRecord.fromJson(Map<String, dynamic> srcJson) =>
      _$CrossChainRecordFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CrossChainRecordToJson(this);
}
