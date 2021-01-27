import 'package:json_annotation/json_annotation.dart';

part 'rp_share_entity.g.dart';

@JsonSerializable()
class RpShareEntity extends Object {
  @JsonKey(name: 'details')
  List<RpShareOpenEntity> details;

  @JsonKey(name: 'info')
  RpShareSendEntity info;

  RpShareEntity(
    this.details,
    this.info,
  );

  factory RpShareEntity.fromJson(Map<String, dynamic> srcJson) => _$RpShareEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpShareEntityToJson(this);
}

@JsonSerializable()
class RpShareOpenEntity extends Object {
  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'avatar')
  String avatar;

  @JsonKey(name: 'hynAmount')
  String hynAmount;

  @JsonKey(name: 'isBest')
  bool isBest;

  @JsonKey(name: 'rpAmount')
  String rpAmount;

  @JsonKey(name: 'username')
  String username;

  @JsonKey(name: 'createdAt')
  int createdAt;

  @JsonKey(name: 'location')
  String location;

  @JsonKey(name: 'getHYNAmount')
  String getHYNAmount;

  @JsonKey(name: 'getRPAmount')
  String getRPAmount;

  @JsonKey(name: 'range')
  double range;

  @JsonKey(name: 'rpType')
  String rpType;

  @JsonKey(name: 'greeting')
  String greeting;

  @JsonKey(name: 'rpHash')
  String rpHash;

  @JsonKey(name: 'hynHash')
  String hynHash;

  RpShareOpenEntity(
    this.id,
    this.address,
    this.avatar,
    this.hynAmount,
    this.isBest,
    this.rpAmount,
    this.username,
    this.createdAt,
    this.location,
    this.getHYNAmount,
    this.getRPAmount,
    this.range,
    this.rpType,
    this.greeting,
    this.rpHash,
    this.hynHash,
  );

  factory RpShareOpenEntity.fromJson(Map<String, dynamic> srcJson) =>
      _$RpShareOpenEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpShareOpenEntityToJson(this);
}

@JsonSerializable()
class RpShareSendEntity extends Object {
  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'alreadyGot')
  bool alreadyGot;

  @JsonKey(name: 'avatar')
  String avatar;

  @JsonKey(name: 'coordinates')
  List<double> coordinates;

  @JsonKey(name: 'createdAt')
  int createdAt;

  @JsonKey(name: 'greeting')
  String greeting;

  @JsonKey(name: 'hasPWD')
  bool hasPWD;

  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'isNewBee')
  bool isNewBee;

  @JsonKey(name: 'owner')
  String owner;

  @JsonKey(name: 'range')
  double range;

  @JsonKey(name: 'rpType')
  String rpType;

  @JsonKey(name: 'state')
  String state;

  @JsonKey(name: 'userIsNewBee')
  bool userIsNewBee;

  @JsonKey(name: 'location')
  String location;

  @JsonKey(name: 'total')
  int total;

  @JsonKey(name: 'gotCount')
  int gotCount;

  @JsonKey(name: 'hynAmount')
  String hynAmount;

  @JsonKey(name: 'rpAmount')
  String rpAmount;

  @JsonKey(name: 'rpHash')
  String rpHash;

  @JsonKey(name: 'hynHash')
  String hynHash;

  @JsonKey(name: 'lat')
  double lat;

  @JsonKey(name: 'lng')
  double lng;

  @JsonKey(name: 'HYNRefundHash')
  String hynRefundHash;

  @JsonKey(name: 'RPRefundHash')
  String rpRefundHash;

  RpShareSendEntity(
    this.address,
    this.alreadyGot,
    this.avatar,
    this.coordinates,
    this.createdAt,
    this.greeting,
    this.hasPWD,
    this.id,
    this.isNewBee,
    this.owner,
    this.range,
    this.rpType,
    this.state,
    this.userIsNewBee,
    this.location,
    this.total,
    this.gotCount,
    this.hynAmount,
    this.rpAmount,
    this.rpHash,
    this.hynHash,
    this.lat,
    this.lng,
    this.hynRefundHash,
    this.rpRefundHash,
  );

  factory RpShareSendEntity.fromJson(Map<String, dynamic> srcJson) =>
      _$RpShareSendEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpShareSendEntityToJson(this);
}
