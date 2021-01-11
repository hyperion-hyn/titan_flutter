import 'package:json_annotation/json_annotation.dart';

part 'rp_share_req_entity.g.dart';

@JsonSerializable()
class RpShareReqEntity extends Object {
  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'coordinates')
  List<double> coordinates;

  @JsonKey(name: 'count')
  int count;

  @JsonKey(name: 'greeting')
  String greeting;

  @JsonKey(name: 'hynamount')
  String hynAmount;

  @JsonKey(name: 'hynsignedTX')
  String hynSignedTX;

  @JsonKey(name: 'isNewBee')
  bool isNewBee;

  @JsonKey(name: 'password')
  String password;

  @JsonKey(name: 'range')
  double range;

  @JsonKey(name: 'rpamount')
  String rpAmount;

  @JsonKey(name: 'rpsignedTX')
  String rpSignedTX;

  @JsonKey(name: 'rptype')
  String rpType;

  RpShareReqEntity(
    this.id,
    this.address,
    this.coordinates,
    this.count,
    this.greeting,
    this.hynAmount,
    this.hynSignedTX,
    this.isNewBee,
    this.password,
    this.range,
    this.rpAmount,
    this.rpSignedTX,
    this.rpType,
  );

  RpShareReqEntity.only(this.id);

  factory RpShareReqEntity.fromJson(Map<String, dynamic> srcJson) => _$RpShareReqEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpShareReqEntityToJson(this);
}
