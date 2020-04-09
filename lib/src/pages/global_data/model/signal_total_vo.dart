import 'package:json_annotation/json_annotation.dart'; 
  
part 'signal_total_vo.g.dart';


@JsonSerializable()
  class SignalTotalVo extends Object {

  @JsonKey(name: 'gps_total')
  int gpsTotal;

  @JsonKey(name: 'wifi_total')
  int wifiTotal;

  @JsonKey(name: 'blue_tooth_total')
  int blueToothTotal;

  @JsonKey(name: 'cellular_total')
  int cellularTotal;

  SignalTotalVo(this.gpsTotal,this.wifiTotal,this.blueToothTotal,this.cellularTotal,);

  factory SignalTotalVo.fromJson(Map<String, dynamic> srcJson) => _$SignalTotalVoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$SignalTotalVoToJson(this);

}

  
