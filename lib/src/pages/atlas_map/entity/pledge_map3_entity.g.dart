// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pledge_map3_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PledgeMap3Entity _$PledgeMap3EntityFromJson(Map<String, dynamic> json) {
  return PledgeMap3Entity(
    payload: json['payload'] == null
        ? null
        : Payload.fromJson(json['payload'] as Map<String, dynamic>),
    rawTx: json['raw_tx'] as String,
  );
}

Map<String, dynamic> _$PledgeMap3EntityToJson(PledgeMap3Entity instance) =>
    <String, dynamic>{
      'payload': instance.payload?.toJson(),
      'raw_tx': instance.rawTx,
    };

Payload _$PayloadFromJson(Map<String, dynamic> json) {
  return Payload(
    userEmail: json['user_email'] as String,
    userIdentity: json['user_identity'] as String,
    userName: json['user_name'] as String,
    userPic: json['user_pic'] as String,
  );
}

Map<String, dynamic> _$PayloadToJson(Payload instance) => <String, dynamic>{
      'user_email': instance.userEmail,
      'user_identity': instance.userIdentity,
      'user_name': instance.userName,
      'user_pic': instance.userPic,
    };

WalletInfoEntity _$WalletInfoEntityFromJson(Map<String, dynamic> json) {
  return WalletInfoEntity(
    address: json['address'] as String,
    name: json['name'] as String,
    pic: json['pic'] as String,
    status: json['status'] as int,
  );
}

Map<String, dynamic> _$WalletInfoEntityToJson(WalletInfoEntity instance) =>
    <String, dynamic>{
      'address': instance.address,
      'name': instance.name,
      'pic': instance.pic,
      'status': instance.status,
    };
