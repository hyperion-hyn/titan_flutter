import 'package:json_annotation/json_annotation.dart'; 
  
part 'signal_weekly_vo.g.dart';


@JsonSerializable()
  class SignalWeeklyVo extends Object {

  @JsonKey(name: 'blue_tooth_count')
  int blueToothCount;

  @JsonKey(name: 'cellular_count')
  int cellularCount;

  @JsonKey(name: 'gps_count')
  int gpsCount;

  @JsonKey(name: 'wifi_count')
  int wifiCount;

  SignalWeeklyVo(this.blueToothCount,this.cellularCount,this.gpsCount,this.wifiCount,);

  factory SignalWeeklyVo.fromJson(Map<String, dynamic> srcJson) => _$SignalWeeklyVoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$SignalWeeklyVoToJson(this);

}

  
