import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/data/entity/heaven_map_poi_info.dart';
import 'package:titan/src/data/entity/poi_interface.dart';

@immutable
abstract class HomeEvent {}

//event bus
class RouteClickEvent extends HomeEvent {
  final String profile;
  final IPoi toPoi;

  RouteClickEvent({
    this.profile = 'driving',
    this.toPoi,
  });
}

class MapOperatingEvent extends HomeEvent {
}

class HomeInitEvent extends HomeEvent {
}