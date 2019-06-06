import 'package:json_annotation/json_annotation.dart';

//see more example https://github.com/dart-lang/json_serializable/blob/master/example/lib/json_converter_example.dart

part 'search_poi.g.dart';

@JsonSerializable()
class SearchPoiEntity {
  final String name;
  final String address;
  final String tags;
  final List<double> loc;
  final String phone;
  bool isHistory;

  SearchPoiEntity({this.name, this.address, this.tags, this.loc, this.phone, this.isHistory});

  factory SearchPoiEntity.fromJson(Map<String, dynamic> json) => _$SearchPoiEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SearchPoiEntityToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
