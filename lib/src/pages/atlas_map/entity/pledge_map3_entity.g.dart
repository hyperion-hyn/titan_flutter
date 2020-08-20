// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pledge_map3_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PledgeMap3Entity _$PledgeMap3EntityFromJson(Map<String, dynamic> json) {
  return PledgeMap3Entity(
    json['amount'] as int,
    json['from'] as String,
    json['gas_limit'] as int,
    json['nonce'] as int,
    json['payload'] == null
        ? null
        : PledgeMap3Payload.fromJson(json['payload'] as Map<String, dynamic>),
    json['price'] as int,
    json['raw_tx'] as String,
    json['to'] as String,
    json['type'] as int,
  );
}

Map<String, dynamic> _$PledgeMap3EntityToJson(PledgeMap3Entity instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'from': instance.from,
      'gas_limit': instance.gasLimit,
      'nonce': instance.nonce,
      'payload': instance.payload,
      'price': instance.price,
      'raw_tx': instance.rawTx,
      'to': instance.to,
      'type': instance.type,
    };

PledgeMap3Payload _$PledgeMap3PayloadFromJson(Map<String, dynamic> json) {
  return PledgeMap3Payload(
    json['map3_node_id'] as String,
    json['staking'] as int,
  );
}

Map<String, dynamic> _$PledgeMap3PayloadToJson(PledgeMap3Payload instance) =>
    <String, dynamic>{
      'map3_node_id': instance.map3NodeId,
      'staking': instance.staking,
    };
