// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RPStatistics _$RPStatisticsFromJson(Map<String, dynamic> json) {
  return RPStatistics(
    json['global'] == null
        ? null
        : Global.fromJson(json['global'] as Map<String, dynamic>),
    json['self'] == null
        ? null
        : Self.fromJson(json['self'] as Map<String, dynamic>),
    json['rp_contract_info'] == null
        ? null
        : Rp_contract_info.fromJson(
            json['rp_contract_info'] as Map<String, dynamic>),
    json['rp_holding_contract_info'] == null
        ? null
        : Rp_holding_contract_info.fromJson(
            json['rp_holding_contract_info'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RPStatisticsToJson(RPStatistics instance) =>
    <String, dynamic>{
      'global': instance.global,
      'self': instance.self,
      'rp_contract_info': instance.rpContractInfo,
    };

Global _$GlobalFromJson(Map<String, dynamic> json) {
  return Global(
    json['total_staking_hyn'] as String,
    json['transmit'] as String,
    json['total_transmit'] as String,
  );
}

Map<String, dynamic> _$GlobalToJson(Global instance) => <String, dynamic>{
      'total_staking_hyn': instance.totalStakingHyn,
      'transmit': instance.transmit,
      'total_transmit': instance.totalTransmit,
    };

Self _$SelfFromJson(Map<String, dynamic> json) {
  return Self(
    json['total_staking_hyn'] as String,
    json['total_amount'] as int,
    json['total_rp'] as String,
    json['yesterday'] as String,
    json['friends'] as int,
  );
}

Map<String, dynamic> _$SelfToJson(Self instance) => <String, dynamic>{
      'total_staking_hyn': instance.totalStakingHyn,
      'total_amount': instance.totalAmount,
      'total_rp': instance.totalRp,
      'yesterday': instance.yesterday,
      'friends': instance.friends,
    };

Rp_contract_info _$Rp_contract_infoFromJson(Map<String, dynamic> json) {
  return Rp_contract_info(
    json['base_rp'] as String,
    json['hyn_per_rp'] as String,
    json['release_day'] as int,
    json['staking_day'] as int,
    json['drop_on_percent'] as int,
    json['pool_percent'] as int,
  );
}

Map<String, dynamic> _$Rp_contract_infoToJson(Rp_contract_info instance) =>
    <String, dynamic>{
      'base_rp': instance.baseRp,
      'hyn_per_rp': instance.hynPerRp,
      'release_day': instance.releaseDay,
      'staking_day': instance.stakingDay,
      'drop_on_percent': instance.dropOnPercent,
      'pool_percent': instance.poolPercent,
    };

Rp_holding_contract_info _$Rp_holding_contract_infoFromJson(Map<String, dynamic> json) {
  return Rp_holding_contract_info(
    json['promotion_supply_ratio'] as String,
    json['total_burning'] as String,
    json['total_holding'] as String,
    json['total_supply'] as String,
    json['random_min_level'] as int,
    json['gradient_ratio'] as String,
  );
}

Map<String, dynamic> _$Rp_holding_contract_infoToJson(Rp_holding_contract_info instance) =>
    <String, dynamic>{
      'promotion_supply_ratio': instance.promotionSupplyRatio,
      'total_burning': instance.totalBurning,
      'total_holding': instance.totalHolding,
      'total_supply': instance.totalSupply,
      'random_min_level': instance.randomMinLevel,
      'gradient_ratio': instance.gradientRatio,
    };
