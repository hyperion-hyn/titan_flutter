// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fund_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FundToken _$FundTokenFromJson(Map<String, dynamic> json) {
  return FundToken(
    json['expire_at'] as int,
    json['token'] as String,
    json['user_id'] as String,
  );
}

Map<String, dynamic> _$FundTokenToJson(FundToken instance) => <String, dynamic>{
      'expire_at': instance.expireAt,
      'token': instance.token,
      'user_id': instance.userId,
    };
