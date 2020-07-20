import 'package:meta/meta.dart';

@immutable
abstract class SocketState {}

class InitialSocketState extends SocketState {}

// SubChannel
class SubChannelState extends SocketState {
  final String period;
  SubChannelState({this.period});
}

class SubChannelSuccessState extends SocketState {
  final Map<String, dynamic> response;
  SubChannelSuccessState({this.response});
}

class SubChannelFailState extends SocketState {}

// UnSubChannel
class UnSubChannelState extends SocketState {
  final String period;
  UnSubChannelState({this.period});
}

class UnSubChannelSuccessState extends SocketState {
  final Map<String, dynamic> response;
  UnSubChannelSuccessState({this.response});
}

class UnSubChannelFailState extends SocketState {}

// ReceivedData
class ReceivedDataState extends SocketState {
  final Map<String, dynamic> response;

  ReceivedDataState({this.response});
}

class ReceivedDataSuccessState extends SocketState {
  final Map<String, dynamic> response;
  ReceivedDataSuccessState({this.response});
}

class ReceivedDataFailState extends SocketState {}


