// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_payload_with_address_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPayloadWithAddressEntity _$UserPayloadWithAddressEntityFromJson(Map<String, dynamic> json) {
  return UserPayloadWithAddressEntity(
    json['payload'] == null
        ? null
        : Payload.fromJson(json['payload'] as Map<String, dynamic>),
    json['address'] as String,
  );
}

Map<String, dynamic> _$UserPayloadWithAddressEntityToJson(UserPayloadWithAddressEntity instance) =>
    <String, dynamic>{
      'payload': instance.payload,
      'address': instance.address,
    };