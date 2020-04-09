import 'package:json_annotation/json_annotation.dart';

part 'experience_info_v2.g.dart';

@JsonSerializable()
class ExperienceInfoV2 {

  @JsonKey(name: "canBuy")
  int canBuy;
  @JsonKey(name: "total")
  int total;
  ExperienceInfoV2(this.canBuy, this.total);

  factory ExperienceInfoV2.fromJson(Map<String, dynamic> json) => _$ContractInfoV2FromJson(json);

  Map<String, dynamic> toJson() => _$ContractInfoV2ToJson(this);
}
