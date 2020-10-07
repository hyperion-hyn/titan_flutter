import 'package:json_annotation/json_annotation.dart'; 
  
part 'bls_key_sign_entity.g.dart';


@JsonSerializable()
  class BlsKeySignEntity extends Object {

  @JsonKey(name: 'bls_key')
  String blsKey;

  @JsonKey(name: 'bls_sign')
  String blsSign;

  BlsKeySignEntity(this.blsKey,this.blsSign,);

  factory BlsKeySignEntity.fromJson(Map<String, dynamic> srcJson) => _$BlsKeySignEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$BlsKeySignEntityToJson(this);

}

  
