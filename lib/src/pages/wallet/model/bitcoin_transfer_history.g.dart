// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bitcoin_transfer_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BitcoinTransferHistory _$BitcoinTransferHistoryFromJson(
    Map<String, dynamic> json) {
  return BitcoinTransferHistory(
    json['from_addr'] as String,
    json['to_addr'] as String,
    json['n_confirmed'] as int,
    json['confirm_at'] as int,
    json['amount'] as int,
    json['fee'] as int,
    json['tx_hash'] as String,
    json['third_addr'] as String,
  );
}

Map<String, dynamic> _$BitcoinTransferHistoryToJson(
        BitcoinTransferHistory instance) =>
    <String, dynamic>{
      'from_addr': instance.fromAddr,
      'to_addr': instance.toAddr,
      'n_confirmed': instance.nConfirmed,
      'confirm_at': instance.confirmAt,
      'amount': instance.amount,
      'fee': instance.fee,
      'tx_hash': instance.txHash,
      'third_addr': instance.thirdAddr,
    };
