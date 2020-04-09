import 'package:json_annotation/json_annotation.dart';

import 'latlng.dart';

part 'signal_collector.g.dart';

@JsonSerializable()
class SignalCollector {
  LatLng location;
  Map data;

  SignalCollector(this.location, this.data);

  factory SignalCollector.fromJson(Map<String, dynamic> json) => _$SignalCollectorFromJson(json);

  Map<String, dynamic> toJson() => _$SignalCollectorToJson(this);
}
