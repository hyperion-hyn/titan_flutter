import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_k_chart/entity/k_line_entity.dart';
import 'package:titan/src/components/socket/bloc/bloc.dart';
import 'package:titan/src/components/socket/socket_config.dart';
import 'package:titan/src/pages/market/entity/market_item_entity.dart';
import 'package:titan/src/pages/market/exchange/exchange_page.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:web_socket_channel/io.dart';

class SocketComponent extends StatelessWidget {
  final Widget child;

  SocketComponent({@required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SocketBloc>(
      create: (ctx) => SocketBloc(),
      child: _SocketManager(child: child),
    );
  }
}

class _SocketManager extends StatefulWidget {
  final Widget child;

  _SocketManager({@required this.child});

  @override
  State<StatefulWidget> createState() {
    return _SocketState();
  }
}

class _SocketState extends State<_SocketManager> {
  IOWebSocketChannel _socketChannel;

  SocketBloc _bloc;
  List<MarketItemEntity> _marketItemList;
  List<List<String>> _tradeDetailList;
  Timer _timer;
//  var hynusdtTradeChannel = SocketConfig.channelTradeDetail("hynusdt");
//  var hynethTradeChannel = SocketConfig.channelTradeDetail("hyneth");
  Set<String> _channelList = Set();
  bool _connectSuccess = false;
 
  @override
  void initState() {
    super.initState();

    _initWS();
    _initBloc();
    _initData();
  }

  @override
  void dispose() {
    print('[WS]  closed');

    _socketChannel.sink.close();
    _bloc.close();
    super.dispose();
  }

  _initWS() {
    print('[WS]  init');
    _socketChannel = IOWebSocketChannel.connect(SocketConfig.domain);

    print('[WS]  listen');
    _socketChannel.stream.listen((data) {
      print('[WS]  listen..., data');

      if (!_connectSuccess) {
        _connectSuccess = true;
        print('[WS]  listen..., data, Socket 连接成功， 发起订阅！');

        for (var channel in _channelList) {
          print('[WS]  listen..., data, Socket 连接成功， 发起订阅， channel:$channel');

          _bloc.add(SubChannelEvent(channel: channel));
        }
      }
      _bloc.add(ReceivedDataEvent(data: data));
    }, onDone: () {
      print('[WS] Done!');

      if (_timer != null && _timer.isActive) {
        _timer.cancel();
        _timer = null;
      }

      _reconnectWS();
    }, onError: (e) {
      // e is :WebSocketChannelException
      print('[WS] Error, e:$e');
    });

    // 心跳，预防一分钟没有消息，自动断开链接。
    if (_timer == null) {
      _timer = Timer.periodic(Duration(seconds: 30), (t) {
        _bloc.add(HeartEvent());
      });
    }
  }

  _initBloc() {
    _bloc = BlocProvider.of<SocketBloc>(context);
    _bloc.setSocketChannel(_socketChannel);
  }

  _initData() {
    // 24hour
    _bloc.add(SubChannelEvent(channel: SocketConfig.channelKLine24Hour));

    // Market
    _bloc.add(MarketSymbolEvent());

    // trade
//    _bloc.add(SubChannelEvent(channel: hynusdtTradeChannel));
//    _bloc.add(SubChannelEvent(channel: hynethTradeChannel));
  }

  _reconnectWS() {
    print('[WS] Reconnect!');

    Future.delayed(Duration(milliseconds: 1000)).then((_) {
      _initWS();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SocketBloc, SocketState>(
      listener: (context, state) async {
        if (state is MarketSymbolState) {
          _marketItemList = state.marketItemList;
        } else if (state is ChannelKLine24HourState) {
          _updateMarketItemList(state.response, symbol: state.symbol);
        } else if (state is ChannelTradeDetailState) {
          _tradeDetailList = state.response.map((item) => (item as List).map((e) => e.toString()).toList()).toList();
        } else if (state is SubChannelState) {
          _channelList.add(state.channel);
        } else if (state is UnSubChannelState) {
          _channelList.remove(state.channel);
        }
      },
      child: BlocBuilder<SocketBloc, SocketState>(
        builder: (context, state) {
          return MarketInheritedModel(
            marketItemList: _marketItemList,
            tradeDetailList: _tradeDetailList,
            child: widget.child,
          );
        },
      ),
    );
  }

  _updateMarketItemList(dynamic data, {String symbol = ''}) {
    if (!(data is List)) {
      return;
    }

    List dataList = data;
    List kLineDataList = dataList.map((item) {
      Map<String, dynamic> json = {};
      if (item is List) {
        List itemList = item;
        if (itemList.length >= 7) {
          json = {
            'open': double.parse(itemList[1].toString()),
            'high': double.parse(itemList[2].toString()),
            'low': double.parse(itemList[3].toString()),
            'close': double.parse(itemList[4].toString()),
            'vol': double.parse(itemList[5].toString()),
            'amount': double.parse(itemList[6].toString()),
            'count': 0,
            'id': int.parse(itemList[0].toString()) / 1000,
          };
        }
      }
      return KLineEntity.fromJson(json);
    }).toList();

    if (_marketItemList == null || _marketItemList.isEmpty) {
      return;
    }

    bool _isNewSymbol = true;
    /*_marketItemList.forEach((element) {
      // replace
      if (element.symbol == symbol) {
        _isNewSymbol = false;
        element = MarketItemEntity(
          symbol,
          kLineDataList.last,
          symbolName: element.symbolName,
        );
      }
    });*/

    int index;
    for (var i=0; i<_marketItemList.length; i++) {
      var element = _marketItemList[i];
      // replace
      if (element.symbol == symbol) {
        index = i;
        break;
      }
    }

    _isNewSymbol = index == null;


    // add
    if (_isNewSymbol) {
      _marketItemList.add(MarketItemEntity(symbol, kLineDataList.first));
    } else {
      var lastElement = _marketItemList[index];
      var element = MarketItemEntity(
        lastElement.symbol,
        kLineDataList.first,
        symbolName: lastElement.symbolName,
      );
      _marketItemList[index] = element;
    }
  }
}

class MarketInheritedModel extends InheritedModel<String> {
  final List<MarketItemEntity> marketItemList;
  final List<List<String>> tradeDetailList;

  const MarketInheritedModel({
    Key key,
    @required this.marketItemList,
    @required this.tradeDetailList,
    @required Widget child,
  }) : super(key: key, child: child);

  MarketItemEntity getMarketItem(String symbol) {
    if (marketItemList == null) {
      return null;
    }

    MarketItemEntity marketItemEntity;
    marketItemList.forEach((element) {
      if (element.symbol == symbol) {
        marketItemEntity = element;
      }
    });
    return marketItemEntity;
  }

  String getRealTimePrice(String symbol) {
    var marketItem = getMarketItem(symbol);
    return marketItem?.kLineEntity?.close?.toString() ?? "0";
  }

  @deprecated
  String getCurrentSymbolRealTimePrice() {
    if (tradeDetailList != null && tradeDetailList.length > 0) {
      var tradeDetail = tradeDetailList[0];
      Decimal tradeDecimal = Decimal.parse(tradeDetail[1]);
      return FormatUtil.truncateDecimalNum(tradeDecimal, 4);
    }
    return "0";
  }

  //buy 为 true , sell 为 false
  @deprecated
  bool isBuyCurrentSymbolRealTimeDirection() {
    if (tradeDetailList != null && tradeDetailList.length > 0) {
      var tradeDetail = tradeDetailList[0];
      var direction = tradeDetail[3];
      return direction == "buy";
    }
    return true;
  }

  double getRealTimePricePercent(String symbol) {
    var marketItem = getMarketItem(symbol);
    var realPercent = marketItem == null
        ? 0.0
        : ((marketItem.kLineEntity?.close ?? 0.0 - marketItem.kLineEntity?.open) / marketItem.kLineEntity?.open ?? 1.0);
    return realPercent;
  }

  double get24HourAmount(String symbol) {
    var marketItem = getMarketItem(symbol);
    var amount = marketItem == null ? 0.0 : (marketItem.kLineEntity?.amount ?? 0.0);
    return amount;
  }

  static MarketInheritedModel of(BuildContext context) {
    return InheritedModel.inheritFrom<MarketInheritedModel>(
      context,
    );
  }

  @override
  bool updateShouldNotify(MarketInheritedModel old) {
    return marketItemList != old.marketItemList || tradeDetailList != old.tradeDetailList;
  }

  @override
  bool updateShouldNotifyDependent(
    MarketInheritedModel old,
    Set<String> dependencies,
  ) {
    return marketItemList != old.marketItemList || tradeDetailList != old.tradeDetailList;
  }
}
