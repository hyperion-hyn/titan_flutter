import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/business/scaffold_map/dmap/dmap.dart';

@immutable
abstract class DiscoverEvent {}

class InitDiscoverEvent extends DiscoverEvent {}

class ActiveDMapEvent extends DiscoverEvent {
  final String name;

  ActiveDMapEvent({this.name});
}
