// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_level_airdrop_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpLevelAirdropInfo _$RpLevelAirdropInfoFromJson(Map<String, dynamic> json) {
  return RpLevelAirdropInfo(
    json['total_amount'] as String,
    json['per_level_amount'] == null
        ? null
        : Per_level_amount.fromJson(
            json['per_level_amount'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RpLevelAirdropInfoToJson(RpLevelAirdropInfo instance) =>
    <String, dynamic>{
      'total_amount': instance.totalAmount,
      'per_level_amount': instance.perLevelAmount,
    };

Per_level_amount _$Per_level_amountFromJson(Map<String, dynamic> json) {
  return Per_level_amount(
    json['1'] as String,
    json['2'] as String,
    json['3'] as String,
    json['4'] as String,
    json['5'] as String,
  );
}

Map<String, dynamic> _$Per_level_amountToJson(Per_level_amount instance) =>
    <String, dynamic>{
      '1': instance.level1,
      '2': instance.level2,
      '3': instance.level3,
      '4': instance.level4,
      '5': instance.level5,
    };
