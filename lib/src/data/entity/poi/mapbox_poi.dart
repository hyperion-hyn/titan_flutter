import 'package:json_annotation/json_annotation.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import './search_history_aware_poi.dart';
import '../converter/model_converter.dart';
import 'poi_interface.dart';

//see more example https://github.com/dart-lang/json_serializable/blob/master/example/lib/json_converter_example.dart

part 'mapbox_poi.g.dart';

class MapBoxPoi with SearchHistoryAwarePoi implements IPoi {
  String name;
  String address;
  String tags;
  @JsonKey(fromJson: LatLngConverter.latLngFromJson, toJson: LatLngConverter.latLngToJson)
  LatLng latLng;
  String phone;
  String remark;

  MapBoxPoi({this.name, this.address, this.tags, this.latLng, this.phone, this.remark, bool isHistory}) {
    this.isHistory = isHistory;
  }

  factory MapBoxPoi.fromJson(Map<String, dynamic> json) => _$PoiEntityFromJson(json);

  Map<String, dynamic> toJson() => _$PoiEntityToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
