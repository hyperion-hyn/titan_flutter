import 'package:json_annotation/json_annotation.dart'; 
  
part 'signal_daily_vo.g.dart';


@JsonSerializable()
  class SignalDailyVo extends Object {

  @JsonKey(name: 'gps')
  List<Signal> gps;

  @JsonKey(name: 'wifi')
  List<Signal> wifi;

  @JsonKey(name: 'blue_tooth')
  List<Signal> blueTooth;

  @JsonKey(name: 'cellular')
  List<Signal> cellular;

  SignalDailyVo(this.gps,this.wifi,this.blueTooth,this.cellular,);

  factory SignalDailyVo.fromJson(Map<String, dynamic> srcJson) => _$SignalDailyVoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$SignalDailyVoToJson(this);

}

  
@JsonSerializable()
  class Signal extends Object {

  @JsonKey(name: 'day')
  String day;

  @JsonKey(name: 'count')
  int count;

  Signal(this.day,this.count,);

  factory Signal.fromJson(Map<String, dynamic> srcJson) => _$SignalFromJson(srcJson);

  Map<String, dynamic> toJson() => _$SignalToJson(this);

}

  
