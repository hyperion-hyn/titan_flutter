// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_banner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExchangeBanner _$ExchangeBannerFromJson(Map<String, dynamic> json) {
  return ExchangeBanner(
    json['id'] as String,
    json['url'] as String,
    json['html'] as String,
    json['onShow'] as String,
    json['expire'] as String,
  );
}

Map<String, dynamic> _$ExchangeBannerToJson(ExchangeBanner instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'html': instance.html,
      'onShow': instance.onShow,
      'expire': instance.expire,
    };
