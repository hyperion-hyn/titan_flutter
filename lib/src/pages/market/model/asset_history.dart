import 'package:json_annotation/json_annotation.dart';

part 'asset_history.g.dart';


@JsonSerializable()
class AssetHistory extends Object {

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'type')
  String type;

  @JsonKey(name: 'balance')
  String balance;

  @JsonKey(name: 'fee')
  String fee;

  @JsonKey(name: 'tx_id')
  String txId;

  @JsonKey(name: 'status')
  String status;

  @JsonKey(name: 'mtime')
  String mtime;

  @JsonKey(name: 'ctime')
  String ctime;

  AssetHistory(this.name,this.id,this.type,this.balance,this.fee,this.txId,this.status,this.mtime,this.ctime,);

  factory AssetHistory.fromJson(Map<String, dynamic> srcJson) => _$AssetHistoryFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AssetHistoryToJson(this);

}


