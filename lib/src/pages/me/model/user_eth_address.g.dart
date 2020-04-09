// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_eth_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserEthAddress _$UserEthAddressFromJson(Map<String, dynamic> json) {
  return UserEthAddress(
    json['address'] as String,
    json['qr_code'] as String,
  );
}

Map<String, dynamic> _$UserEthAddressToJson(UserEthAddress instance) =>
    <String, dynamic>{
      'address': instance.address,
      'qr_code': instance.qrCode,
    };
