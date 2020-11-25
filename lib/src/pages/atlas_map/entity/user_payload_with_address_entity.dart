import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';

part 'user_payload_with_address_entity.g.dart';


@JsonSerializable()
class UserPayloadWithAddressEntity extends Object {

  @JsonKey(name: 'payload')
  Payload payload;

  @JsonKey(name: 'address')
  String address;

  UserPayloadWithAddressEntity(this.payload,this.address,);

  factory UserPayloadWithAddressEntity.fromJson(Map<String, dynamic> srcJson) => _$UserPayloadWithAddressEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$UserPayloadWithAddressEntityToJson(this);

}