import 'package:meta/meta.dart';

@immutable
abstract class SocketState {}

class InitialSocketState extends SocketState {}

// SubChannel
class SubChannelState extends SocketState {
  final String period;
  SubChannelState({this.period});
}

class SubChannelSuccessState extends SocketState {}

class SubChannelFailState extends SocketState {}

// UnSubChannel
class UnSubChannelState extends SocketState {
  final String period;
  UnSubChannelState({this.period});
}

class UnSubChannelSuccessState extends SocketState {}

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

class HeartState extends SocketState {}

class HeartSuccessState extends SocketState {}

class ChannelKLine24HourState extends SocketState {
  final Map<String, dynamic> response;
  ChannelKLine24HourState({this.response});
}

class ChannelKLinePeriodState extends SocketState {
  final String channel;
  final Map<String, dynamic> response;
  ChannelKLinePeriodState({this.channel, this.response});
}

class ChannelExchangeDepthState extends SocketState {
  final Map<String, dynamic> response;
  ChannelExchangeDepthState({this.response});
}

class ChannelTradeDetailState extends SocketState {
  final Map<String, dynamic> response;
  ChannelTradeDetailState({this.response});
}

class ChannelUserTickState extends SocketState {
  final List<dynamic> response;
  ChannelUserTickState({this.response});
}
