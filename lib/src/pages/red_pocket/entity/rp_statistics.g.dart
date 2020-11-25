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
  );
}

Map<String, dynamic> _$RPStatisticsToJson(RPStatistics instance) =>
    <String, dynamic>{
      'global': instance.global,
      'self': instance.self,
    };

Global _$GlobalFromJson(Map<String, dynamic> json) {
  return Global(
    json['hyn'] as int,
    json['total'] as int,
    json['transmit'] as int,
  );
}

Map<String, dynamic> _$GlobalToJson(Global instance) => <String, dynamic>{
      'hyn': instance.hyn,
      'total': instance.total,
      'transmit': instance.transmit,
    };

Self _$SelfFromJson(Map<String, dynamic> json) {
  return Self(
    json['total_hyn'] as int,
    json['total_rp'] as int,
    json['yesterday'] as int,
  );
}

Map<String, dynamic> _$SelfToJson(Self instance) => <String, dynamic>{
      'total_hyn': instance.totalHyn,
      'total_rp': instance.totalRp,
      'yesterday': instance.yesterday,
    };
