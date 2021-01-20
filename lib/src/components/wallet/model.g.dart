// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LegalSign _$LegalSignFromJson(Map<String, dynamic> json) {
  return LegalSign(
    legal: json['legal'] as String,
    sign: json['sign'] as String,
  );
}

Map<String, dynamic> _$LegalSignToJson(LegalSign instance) => <String, dynamic>{
      'legal': instance.legal,
      'sign': instance.sign,
    };
