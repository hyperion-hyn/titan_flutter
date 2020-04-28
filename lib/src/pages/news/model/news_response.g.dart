// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsResponse _$NewsResponseFromJson(Map<String, dynamic> json) {
  return NewsResponse(
    json['id'] as int,
    json['date'] as int,
    json['title'] as String,
    json['custom_cover'] as String,
    json['outlink'] as String,
    json['focus'] == null
        ? null
        : FocusImage.fromJson(json['focus'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$NewsResponseToJson(NewsResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'title': instance.title,
      'custom_cover': instance.customCover,
      'outlink': instance.outlink,
      'focus': instance.focus,
    };
