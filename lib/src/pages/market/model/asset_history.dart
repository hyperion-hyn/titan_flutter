import 'package:json_annotation/json_annotation.dart';

part 'asset_history.g.dart';


@JsonSerializable()
class AssetHistory extends Object {

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'balance')
  double balance;

  @JsonKey(name: 'ctime')
  int ctime;

  @JsonKey(name: 'fee')
  double fee;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'status')
  int status;

  @JsonKey(name: 'txid')
  String txid;

  @JsonKey(name: 'type')
  String type;

  AssetHistory(this.address,this.balance,this.ctime,this.fee,this.id,this.name,this.status,this.txid,this.type,);

  factory AssetHistory.fromJson(Map<String, dynamic> srcJson) => _$AssetHistoryFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AssetHistoryToJson(this);

}


