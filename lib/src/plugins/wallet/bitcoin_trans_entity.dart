import 'package:json_annotation/json_annotation.dart';

part 'bitcoin_trans_entity.g.dart';


@JsonSerializable()
class BitcoinTransEntity extends Object {

  @JsonKey(name: 'fileName')
  String fileName;

  @JsonKey(name: 'password')
  String password;

  @JsonKey(name: 'fromAddress')
  String fromAddress;

  @JsonKey(name: 'toAddress')
  String toAddress;

  @JsonKey(name: 'fee')
  int fee;

  @JsonKey(name: 'amount')
  int amount;

  @JsonKey(name: 'utxo')
  List<Utxo> utxo;

  @JsonKey(name: 'change')
  Change change;

  BitcoinTransEntity(this.fileName,this.password,this.fromAddress,this.toAddress,this.fee,this.amount,this.utxo,this.change,);

  factory BitcoinTransEntity.fromJson(Map<String, dynamic> srcJson) => _$BitcoinTransEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$BitcoinTransEntityToJson(this);

}


@JsonSerializable()
class Utxo extends Object {

  @JsonKey(name: 'sub')
  int sub;

  @JsonKey(name: 'index')
  int index;

  @JsonKey(name: 'tx_hash')
  String txHash;

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'tx_output_n')
  int txOutputN;

  @JsonKey(name: 'value')
  int value;

  Utxo(this.sub,this.index,this.txHash,this.address,this.txOutputN,this.value,);

  factory Utxo.fromJson(Map<String, dynamic> srcJson) => _$UtxoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$UtxoToJson(this);

}


@JsonSerializable()
class Change extends Object {

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'value')
  int value;

  Change(this.address,this.value,);

  factory Change.fromJson(Map<String, dynamic> srcJson) => _$ChangeFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ChangeToJson(this);

}


