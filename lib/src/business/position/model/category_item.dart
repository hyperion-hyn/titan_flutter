import 'package:json_annotation/json_annotation.dart'; 
  
part 'category_item.g.dart';


@JsonSerializable()
  class CategoryItem extends Object {

  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'parent_aliases')
  List<String> parentAliases;

  @JsonKey(name: 'title')
  String title;

  CategoryItem(this.id,this.parentAliases,this.title,);

  factory CategoryItem.fromJson(Map<String, dynamic> srcJson) => _$CategoryItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CategoryItemToJson(this);

}

  
