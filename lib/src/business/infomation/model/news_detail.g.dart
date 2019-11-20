// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsDetail _$NewsDetailFromJson(Map<String, dynamic> json) {
  return NewsDetail(
    json['id'] as int,
    json['date'] as int,
    json['title'] as String,
    json['content'] as String,
    json['custom_cover'] as String,
    json['outlink'] as String,
    json['focus'] == null
        ? null
        : FocusImage.fromJson(json['focus'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$NewsDetailToJson(NewsDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'title': instance.title,
      'content': instance.content,
      'custom_cover': instance.customCover,
      'outlink': instance.outlink,
      'focus': instance.focus,
    };
