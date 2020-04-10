import 'package:json_annotation/json_annotation.dart';

part 'start_join_instance.g.dart';


@JsonSerializable()
class StartJoinInstance extends Object {

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'provider')
  String provider;

  @JsonKey(name: 'region')
  String region;

  StartJoinInstance(this.address,this.provider,this.region);

  factory StartJoinInstance.fromJson(Map<String, dynamic> srcJson) => _$StartJoinInstanceFromJson(srcJson);

  Map<String, dynamic> toJson() => _$StartJoinInstanceToJson(this);

}