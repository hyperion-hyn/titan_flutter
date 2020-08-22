import 'package:json_annotation/json_annotation.dart'; 
  
part 'test_post_entity.g.dart';


@JsonSerializable()
  class TestPostEntity extends Object {

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'pub')
  String pub;

  @JsonKey(name: 'ts')
  int ts;

  @JsonKey(name: 'version')
  String version;

  TestPostEntity(this.address,this.pub,this.ts,this.version,);

  factory TestPostEntity.fromJson(Map<String, dynamic> srcJson) => _$TestPostEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$TestPostEntityToJson(this);

}

  
