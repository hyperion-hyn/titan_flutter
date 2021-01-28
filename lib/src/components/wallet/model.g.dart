// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuotesModel _$QuotesModelFromJson(Map<String, dynamic> json) {
  return QuotesModel(
    quotes: (json['quotes'] as List)
        ?.map((e) => e == null
            ? null
            : TokenPriceViewVo.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$QuotesModelToJson(QuotesModel instance) =>
    <String, dynamic>{
      'quotes': instance.quotes,
    };

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
