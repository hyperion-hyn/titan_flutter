import 'package:json_annotation/json_annotation.dart';

//see more example https://github.com/dart-lang/json_serializable/blob/master/example/lib/json_converter_example.dart

part 'poi.g.dart';

@JsonSerializable()
class PoiEntity {
  final String name;
  final String address;
  final String tags;
  final List<double> loc;
  final String phone;
  final String remark;
  @JsonKey(ignore: true)
  bool isHistory;

  PoiEntity({this.name, this.address, this.tags, this.loc, this.phone, this.remark, this.isHistory});

  factory PoiEntity.fromJson(Map<String, dynamic> json) => _$SearchPoiEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SearchPoiEntityToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
