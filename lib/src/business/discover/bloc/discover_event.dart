import 'package:meta/meta.dart';

@immutable
abstract class DiscoverEvent {}

class InitDiscoverEvent extends DiscoverEvent {}

class ActiveDMapEvent extends DiscoverEvent {
  final String dMapName;

  ActiveDMapEvent({this.dMapName});
}
