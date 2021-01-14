import 'package:json_annotation/json_annotation.dart';

part 'rp_share_req_entity.g.dart';

@JsonSerializable()
class RpShareReqEntity extends Object {
  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'lat')
  double lat;

  @JsonKey(name: 'lng')
  double lng;

  @JsonKey(name: 'count')
  int count;

  @JsonKey(name: 'greeting')
  String greeting;

  @JsonKey(name: 'hynamount')
  double hynAmount;

  @JsonKey(name: 'hynsignedTX')
  String hynSignedTX;

  @JsonKey(name: 'isNewBee')
  bool isNewBee;

  @JsonKey(name: 'password')
  String password;

  @JsonKey(name: 'range')
  double range;

  @JsonKey(name: 'rpamount')
  double rpAmount;

  @JsonKey(name: 'rpsignedTX')
  String rpSignedTX;

  @JsonKey(name: 'rptype')
  String rpType;

  @JsonKey(name: 'location')
  String location;

  RpShareReqEntity(
    this.id,
    this.address,
    this.lat,
    this.lng,
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
    this.location,
  );

  RpShareReqEntity.onlyId(this.id);

  RpShareReqEntity.only(
    this.id,
    this.address,
    this.lat,
    this.lng,
    this.password,
  );

  factory RpShareReqEntity.fromJson(Map<String, dynamic> srcJson) => _$RpShareReqEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpShareReqEntityToJson(this);
}
