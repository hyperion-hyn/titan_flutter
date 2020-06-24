// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bitcoin_trans_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BitcoinTransEntity _$BitcoinTransEntityFromJson(Map<String, dynamic> json) {
  return BitcoinTransEntity(
    json['fileName'] as String,
    json['password'] as String,
    json['fromAddress'] as String,
    json['toAddress'] as String,
    json['fee'] as int,
    json['amount'] as int,
    (json['utxo'] as List)
        ?.map(
            (e) => e == null ? null : Utxo.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['change'] == null
        ? null
        : Change.fromJson(json['change'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$BitcoinTransEntityToJson(BitcoinTransEntity instance) =>
    <String, dynamic>{
      'fileName': instance.fileName,
      'password': instance.password,
      'fromAddress': instance.fromAddress,
      'toAddress': instance.toAddress,
      'fee': instance.fee,
      'amount': instance.amount,
      'utxo': instance.utxo,
      'change': instance.change,
    };

Utxo _$UtxoFromJson(Map<String, dynamic> json) {
  return Utxo(
    json['sub'] as int,
    json['index'] as int,
    json['tx_hash'] as String,
    json['address'] as String,
    json['tx_output_n'] as int,
    json['value'] as int,
  );
}

Map<String, dynamic> _$UtxoToJson(Utxo instance) => <String, dynamic>{
      'sub': instance.sub,
      'index': instance.index,
      'txHash': instance.txHash,
      'address': instance.address,
      'txOutputN': instance.txOutputN,
      'value': instance.value,
    };

Change _$ChangeFromJson(Map<String, dynamic> json) {
  return Change(
    json['address'] as String,
    json['value'] as int,
  );
}

Map<String, dynamic> _$ChangeToJson(Change instance) => <String, dynamic>{
      'address': instance.address,
      'value': instance.value,
    };
