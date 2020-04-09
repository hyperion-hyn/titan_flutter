import 'package:json_annotation/json_annotation.dart';

part 'check_in_model.g.dart';

@JsonSerializable()
class CheckInModel {
  @JsonKey(name: "total")
  int finishTaskNum;
  CheckInDetail detail;

  CheckInModel({this.detail, this.finishTaskNum});

  factory CheckInModel.fromJson(Map<String, dynamic> json) => _$CheckInModelFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInModelToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

//  static Future<CheckInModel> loadFromSharePrefs() async {
//    var today = DateTime.now();
//    var key = PrefsKey.checkInModel + '${today.year}${today.month}${today.day}';
//    var prefs = await SharedPreferences.getInstance();
//    var modelStr = prefs.getString(key);
//    if (modelStr != null) {
//      var model = CheckInModel.fromJson(json.decode(modelStr));
//      return model;
//    }
//    return null;
//  }
//
//  static Future saveToSharePrefs(CheckInModel model) async {
//    var today = DateTime.now();
//    var key = PrefsKey.checkInModel + '${today.year}${today.month}${today.day}';
//    var prefs = await SharedPreferences.getInstance();
//    var modelStr = json.encode(model.toJson());
//    prefs.setString(key, modelStr);
//  }
}

@JsonSerializable()
class CheckInDetail {
  @JsonKey(name: "scanSignal")
  int scanTimes;
  @JsonKey(name: "postPOI")
  int addPoiTimes;
  @JsonKey(name: "confirmPOI")
  int verifyPoiTimes;

  CheckInDetail({this.scanTimes, this.addPoiTimes, this.verifyPoiTimes});

  factory CheckInDetail.fromJson(Map<String, dynamic> json) => _$CheckInDetailFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInDetailToJson(this);
}
