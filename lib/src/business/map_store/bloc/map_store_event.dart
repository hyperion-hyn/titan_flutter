import 'package:equatable/equatable.dart';

abstract class MapStoreEvent extends Equatable {
  MapStoreEvent([List props = const []]) : super(props);
}

class LoadMapStoreItemsEvent extends MapStoreEvent {
  final String channel;

  final String language;

  LoadMapStoreItemsEvent({this.channel, this.language});
}
