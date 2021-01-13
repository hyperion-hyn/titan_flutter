import 'package:json_annotation/json_annotation.dart';

part 'check_in_model.g.dart';

@JsonSerializable()
class CheckInModel extends Object {
  @JsonKey(name: 'day')
  String day;

  @JsonKey(name: 'total')
  int total;

  @JsonKey(name: 'detail')
  List<CheckInModelDetail> detail;

  @JsonKey(name: 'completed')
  bool completed;

  CheckInModel(
    this.day,
    this.total,
    this.detail,
    this.completed,
  );

  factory CheckInModel.fromJson(Map<String, dynamic> srcJson) => _$CheckInModelFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CheckInModelToJson(this);
}

@JsonSerializable()
class CheckInModelDetail extends Object {
  @JsonKey(name: 'action')
  String action;

  @JsonKey(name: 'state')
  CheckInModelState state;

  CheckInModelDetail(
    this.action,
    this.state,
  );

  factory CheckInModelDetail.fromJson(Map<String, dynamic> srcJson) => _$CheckInModelDetailFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CheckInModelDetailToJson(this);
}

@JsonSerializable()
class CheckInModelState extends Object {
  @JsonKey(name: 'total')
  int total;

  @JsonKey(name: 'real')
  int real;

  @JsonKey(name: 'pois')
  List<CheckInModelPoi> pois;

  CheckInModelState(
    this.total,
    this.real,
    this.pois,
  );

  factory CheckInModelState.fromJson(Map<String, dynamic> srcJson) => _$CheckInModelStateFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CheckInModelStateToJson(this);
}

@JsonSerializable()
class CheckInModelPoi extends Object {
  @JsonKey(name: 'poi_id')
  String poiId;

  @JsonKey(name: 'coordinates')
  List<double> coordinates;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'category')
  String category;

  @JsonKey(name: 'phone')
  String phone;

  @JsonKey(name: 'status')
  int status;

  @JsonKey(name: 'ext')
  String ext;

  @JsonKey(name: 'workTime')
  String workTime;

  @JsonKey(name: 'image')
  String image;

  @JsonKey(name: 'isReal')
  bool isReal;

  @JsonKey(name: 'answer')
  bool answer;

  @JsonKey(name: "created_at")
  int createdAt;

  @JsonKey(name: 'originalImgs')
  List<String> originalImgs;

  @JsonKey(name: "poiCreatedAt")
  int poiCreatedAt;

  @JsonKey(name: 'detail')
  List<CheckInModelPoi> detail;

  CheckInModelPoi(
    this.poiId,
    this.coordinates,
    this.name,
    this.address,
    this.category,
    this.phone,
    this.status,
    this.ext,
    this.workTime,
    this.image,
    this.isReal,
    this.answer,
    this.createdAt,
    this.originalImgs,
    this.poiCreatedAt,
    this.detail,
  );

  CheckInModelPoi.onlyByPoiId(this.poiId);

  factory CheckInModelPoi.fromJson(Map<String, dynamic> srcJson) => _$CheckInModelPoiFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CheckInModelPoiToJson(this);
}
