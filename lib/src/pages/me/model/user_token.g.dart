// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserToken _$UserTokenFromJson(Map<String, dynamic> json) {
  return UserToken(
    json['refresh_token'] as String,
    json['token'] as String,
    json['user_id'] as String,
  );
}

Map<String, dynamic> _$UserTokenToJson(UserToken instance) => <String, dynamic>{
      'refresh_token': instance.refreshToken,
      'token': instance.token,
      'user_id': instance.userId,
    };
