// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_expand_info_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletExpandInfoEntity _$WalletExpandInfoEntityFromJson(
    Map<String, dynamic> json) {
  return WalletExpandInfoEntity(
    json['localHeadImg'] as String,
    json['netHeadImg'] as String,
    json['pswRemind'] as String,
  );
}

Map<String, dynamic> _$WalletExpandInfoEntityToJson(
        WalletExpandInfoEntity instance) =>
    <String, dynamic>{
      'localHeadImg': instance.localHeadImg,
      'netHeadImg': instance.netHeadImg,
      'pswRemind': instance.pswRemind,
    };
