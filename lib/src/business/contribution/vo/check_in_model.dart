import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/src/consts/consts.dart';

part 'check_in_model.g.dart';

@JsonSerializable()
class CheckInModel {
  int scanTimes;
  int addPoiTimes;
  int verifyPoiTimes;

  CheckInModel({this.addPoiTimes, this.scanTimes, this.verifyPoiTimes});

  factory CheckInModel.fromJson(Map<String, dynamic> json) => _$CheckInModelFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInModelToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

  static Future<CheckInModel> loadFromSharePrefs() async {
    var today = DateTime.now();
    var key = PrefsKey.checkInModel + '${today.year}${today.month}${today.day}';
    var prefs = await SharedPreferences.getInstance();
    var modelStr = prefs.getString(key);
    if (modelStr != null) {
      var model = CheckInModel.fromJson(json.decode(modelStr));
      return model;
    }
    return null;
  }

  static Future saveToSharePrefs(CheckInModel model) async {
    var today = DateTime.now();
    var key = PrefsKey.checkInModel + '${today.year}${today.month}${today.day}';
    var prefs = await SharedPreferences.getInstance();
    var modelStr = json.encode(model.toJson());
    prefs.setString(key, modelStr);
  }
}
