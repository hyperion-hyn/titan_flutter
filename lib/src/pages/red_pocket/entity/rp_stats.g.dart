// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpStats _$RpStatsFromJson(Map<String, dynamic> json) {
  return RpStats(
    json['global'] == null
        ? null
        : Global.fromJson(json['global'] as Map<String, dynamic>),
    json['airdrop'] == null
        ? null
        : Airdrop.fromJson(json['airdrop'] as Map<String, dynamic>),
    json['transmit'] == null
        ? null
        : Transmit.fromJson(json['transmit'] as Map<String, dynamic>),
    json['promotion'] == null
        ? null
        : Promotion.fromJson(json['promotion'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RpStatsToJson(RpStats instance) => <String, dynamic>{
      'global': instance.global,
      'airdrop': instance.airdrop,
      'transmit': instance.transmit,
      'promotion': instance.promotion,
    };

Global _$GlobalFromJson(Map<String, dynamic> json) {
  return Global(
    json['total_cap'] as String,
    json['total_supply'] as String,
    json['total_burning'] as String,
  );
}

Map<String, dynamic> _$GlobalToJson(Global instance) => <String, dynamic>{
      'total_cap': instance.totalCap,
      'total_supply': instance.totalSupply,
      'total_burning': instance.totalBurning,
    };

Airdrop _$AirdropFromJson(Map<String, dynamic> json) {
  return Airdrop(
    json['total'] as String,
    json['lucky_total'] as String,
    json['level_total'] as String,
    json['promotion_total'] as String,
    json['burning_total'] as String,
  );
}

Map<String, dynamic> _$AirdropToJson(Airdrop instance) => <String, dynamic>{
      'total': instance.total,
      'lucky_total': instance.luckyTotal,
      'level_total': instance.levelTotal,
      'promotion_total': instance.promotionTotal,
      'burning_total': instance.burningTotal,
    };

Transmit _$TransmitFromJson(Map<String, dynamic> json) {
  return Transmit(
    json['total'] as String,
    json['holding_hyn'] as String,
    json['transmit_rp'] as String,
  );
}

Map<String, dynamic> _$TransmitToJson(Transmit instance) => <String, dynamic>{
      'total': instance.total,
      'holding_hyn': instance.holdingHyn,
      'transmit_rp': instance.transmitRp,
    };

Promotion _$PromotionFromJson(Map<String, dynamic> json) {
  return Promotion(
    json['total_holding'] as String,
    json['total_burning'] as String,
  );
}

Map<String, dynamic> _$PromotionToJson(Promotion instance) => <String, dynamic>{
      'total_holding': instance.totalHolding,
      'total_burning': instance.totalBurning,
    };
