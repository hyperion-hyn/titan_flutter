import 'package:meta/meta.dart';

@immutable
abstract class DiscoverEvent {}

class InitDiscoverEvent extends DiscoverEvent {}

class LoadFocusImageEvent extends DiscoverEvent {}

class ActiveDMapEvent extends DiscoverEvent {
  final String name;

  ActiveDMapEvent({this.name});
}
