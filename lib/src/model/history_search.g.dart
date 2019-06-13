// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistorySearchEntity _$HistorySearchEntityFromJson(Map<String, dynamic> json) {
  return HistorySearchEntity(
      id: json['id'] as int,
      time: json['time'] as int,
      searchText: json['search_text'] as String,
      type: json['type'] as String);
}

Map<String, dynamic> _$HistorySearchEntityToJson(
        HistorySearchEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'time': instance.time,
      'search_text': instance.searchText,
      'type': instance.type
    };
