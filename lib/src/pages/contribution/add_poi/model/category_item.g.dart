// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryItem _$CategoryItemFromJson(Map<String, dynamic> json) {
  return CategoryItem(
    json['id'] as String,
    (json['parent_aliases'] as List)?.map((e) => e as String)?.toList(),
    json['title'] as String,
  );
}

Map<String, dynamic> _$CategoryItemToJson(CategoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parent_aliases': instance.parentAliases,
      'title': instance.title,
    };
