// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExchangeAccount _$ExchangeAccountFromJson(Map<String, dynamic> json) {
  return ExchangeAccount(
    json['id'] as String,
    json['email'] as String,
    json['nickname'] as String,
    json['username'] as String,
    json['country'] as String,
    json['activate'] as String,
    json['pn'] as String,
    json['mtime'] as String,
    json['ctime'] as String,
    json['reg_type'] as String,
    json['mobile'] as String,
    json['gesture_token'] as int,
    json['beNew'] as int,
  );
}

Map<String, dynamic> _$ExchangeAccountToJson(ExchangeAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'nickname': instance.nickname,
      'username': instance.username,
      'country': instance.country,
      'activate': instance.activate,
      'pn': instance.pn,
      'mtime': instance.mtime,
      'ctime': instance.ctime,
      'reg_type': instance.regType,
      'mobile': instance.mobile,
      'gesture_token': instance.gestureToken,
      'beNew': instance.beNew,
    };
