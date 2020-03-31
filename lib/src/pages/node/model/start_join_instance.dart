import 'package:json_annotation/json_annotation.dart';

part 'start_join_instance.g.dart';


@JsonSerializable()
class StartJoinInstance extends Object {

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'amount')
  double amount;

  @JsonKey(name: 'data')
  String data;

  StartJoinInstance(this.address,this.name,this.amount,this.data,);

  factory StartJoinInstance.fromJson(Map<String, dynamic> srcJson) => _$StartJoinInstanceFromJson(srcJson);

  Map<String, dynamic> toJson() => _$StartJoinInstanceToJson(this);

}