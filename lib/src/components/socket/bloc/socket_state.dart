import 'package:meta/meta.dart';
import 'package:titan/src/pages/market/entity/market_item_entity.dart';

@immutable
abstract class SocketState {}

class InitialSocketState extends SocketState {}

// SubChannel
class SubChannelState extends SocketState {
  final String channel;
  SubChannelState({this.channel});
}

class SubChannelSuccessState extends SocketState {
  final String channel;
  SubChannelSuccessState({this.channel});
}

class SubChannelFailState extends SocketState {}

// UnSubChannel
class UnSubChannelState extends SocketState {
  final String channel;
  UnSubChannelState({this.channel});
}

class UnSubChannelSuccessState extends SocketState {
  final String channel;
  UnSubChannelSuccessState({this.channel});
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

class HeartState extends SocketState {}

class HeartSuccessState extends SocketState {}

class ChannelKLine24HourState extends SocketState {
  final String symbol;
  final List response;
  ChannelKLine24HourState({this.symbol,this.response});
}

class ChannelKLinePeriodState extends SocketState {
  final String channel;
  final List response;
  ChannelKLinePeriodState({this.channel, this.response});
}

class ChannelExchangeDepthState extends SocketState {
  final Map<String, dynamic> response;
  ChannelExchangeDepthState({this.response,});
}

class ChannelTradeDetailState extends SocketState {
  final List<dynamic> response;
  ChannelTradeDetailState({this.response});
}

class ChannelUserTickState extends SocketState {
  final List<dynamic> response;
  ChannelUserTickState({this.response});
}

class MarketSymbolState extends SocketState {
  final List<MarketItemEntity> marketItemList;
  MarketSymbolState(this.marketItemList);
}