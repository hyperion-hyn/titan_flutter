// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParentUser _$ParentUserFromJson(Map<String, dynamic> json) {
  return ParentUser(
    json['email'] as String,
    json['invitation_code'] as String,
    json['address'] as String,
  );
}

Map<String, dynamic> _$ParentUserToJson(ParentUser instance) =>
    <String, dynamic>{
      'email': instance.email,
      'invitation_code': instance.invitation_code,
      'address': instance.address,
    };
