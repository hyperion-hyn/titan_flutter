import 'package:meta/meta.dart';

@immutable
abstract class SocketEvent {}

class SubChannelEvent extends SocketEvent {
  final String channel;
  SubChannelEvent({this.channel});
}

class UnSubChannelEvent extends SocketEvent {
  final String channel;
  UnSubChannelEvent({this.channel});
}

class ReceivedDataEvent extends SocketEvent {

  final dynamic data;
  ReceivedDataEvent({this.data});
}

class HeartResponseEvent extends SocketEvent {

  final dynamic ping;
  HeartResponseEvent({this.ping});
}
