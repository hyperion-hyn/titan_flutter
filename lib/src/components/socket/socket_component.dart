import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k_chart/flutter_k_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/src/components/socket/bloc/bloc.dart';
import 'package:titan/src/components/socket/socket_config.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/market/api/exchange_const.dart';
import 'package:titan/src/pages/market/entity/market_item_entity.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:web_socket_channel/io.dart';
import 'package:nested/nested.dart';

class SocketComponent extends SingleChildStatelessWidget {

  SocketComponent({Key key, Widget child}): super(key: key, child: child);

  @override
  Widget buildWithChild(BuildContext context, Widget child) {
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

  // 24小时候成交数据
  List<MarketItemEntity> _marketItemList = List();

  // List<List<String>> _tradeDetailList;
  Timer _timer;

//  var hynusdtTradeChannel = SocketConfig.channelTradeDetail("hynusdt");
//  var hynethTradeChannel = SocketConfig.channelTradeDetail("hyneth");
  Set<String> _channelList = Set();
  bool _connecting = false;

  @override
  void initState() {
    super.initState();

    _initBloc();
    _initWS();
    _initData();
  }

  @override
  void dispose() {
    LogUtil.printMessage('[WS]  closed');

    _socketChannel.sink.close();
    _bloc.close();
    super.dispose();
  }

  _initWS() {
    LogUtil.printMessage('[WS]  init');

    _socketChannel = IOWebSocketChannel.connect(ExchangeConst.WS_DOMAIN);
    _bloc.setSocketChannel(_socketChannel);

    _socketChannel.stream.listen((data) {
      //LogUtil.printMessage('[WS]  listen..., data');

      if (!_connecting) {
        _connecting = true;
        LogUtil.printMessage('[WS]  listen..., data, Socket 连接成功， 发起订阅！');

        for (var channel in _channelList) {
          LogUtil.printMessage(
              '[WS]  listen..., data, Socket 连接成功， 发起订阅， channel:$channel');

          _bloc.add(SubChannelEvent(channel: channel));
        }

        _initData();
      }
      _bloc.add(ReceivedDataEvent(data: data));
    }, onDone: () {
      LogUtil.printMessage('[WS] Done!');

      _connecting = false;

      if (_timer != null && _timer.isActive) {
        _timer.cancel();
        _timer = null;
      }

      _reconnectWS();
    }, onError: (e) {
      // e is :WebSocketChannelException
      _socketChannel.sink.close();

      LogUtil.printMessage('[WS] Error, e:$e');
    });

    // 心跳，预防一分钟没有消息，自动断开链接。
    _bloc.add(HeartEvent());

    if (_timer == null) {
      _timer = Timer.periodic(Duration(seconds: 30), (t) {
        _bloc.add(HeartEvent());
      });
    }
  }

  _initBloc() {
    _bloc = BlocProvider.of<SocketBloc>(context);
  }

  _initData() async {
    // 24hour
    _bloc.add(SubChannelEvent(channel: SocketConfig.channelKLine24Hour));

    await _getCacheMarketSymbolList();

    // Market
    _bloc.add(MarketSymbolEvent());

    // trade
//    _bloc.add(SubChannelEvent(channel: hynusdtTradeChannel));
//    _bloc.add(SubChannelEvent(channel: hynethTradeChannel));
  }

  _getCacheMarketSymbolList() async {
    _marketItemList.clear();
    var sharePref = await SharedPreferences.getInstance();
    List<String> emptyMarketItemStrList = sharePref.getStringList(
      PrefsKey.CACHE_MARKET_ITEM_LIST,
    );
    emptyMarketItemStrList?.forEach((element) {
      try {
        var emptyMarketItem = MarketItemEntity.fromJson(jsonDecode(element));
        _marketItemList.add(emptyMarketItem);
      } catch (e) {
        LogUtil.printMessage('_getCacheMarketSymbolList:$e');
      }
    });
    setState(() {});
  }

  _reconnectWS() {
    LogUtil.printMessage('[WS] Reconnect!');
    LogUtil.printMessage('[WS] websocket断开了');
    Future.delayed(Duration(milliseconds: 1000)).then((_) {
      _initWS();
    });

    LogUtil.printMessage('[WS] websocket重连中。。。。');
  }

  DebounceLater cacheDebounceLater = DebounceLater();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SocketBloc, SocketState>(
      listener: (context, state) async {
        if (state is MarketSymbolState) {
          // 24小时候成交数据  api 方式
          _marketItemList = state.marketItemList;
          cacheDebounceLater.debounceInterval(() {
            _cacheSymbolList(_marketItemList);
          }, t: 1000, runImmediately: true);
        } else if (state is ChannelKLine24HourState) {
          // 24小时候成交数据  socket 方式
          _updateMarketItemList(state.response, symbol: state.symbol);
        }
        /*else if (state is ChannelTradeDetailState) {
          _tradeDetailList = state.response.map((item) => (item as List).map((e) => e.toString()).toList()).toList();
        }*/
        else if (state is SubChannelState) {
          _channelList.add(state.channel);
        } else if (state is UnSubChannelState) {
          _channelList.remove(state.channel);
        }
      },
      child: BlocBuilder<SocketBloc, SocketState>(
        builder: (context, state) {
          return MarketInheritedModel(
            marketItemList: _marketItemList,
            // tradeDetailList: _tradeDetailList,
            child: widget.child,
          );
        },
      ),
    );
  }

  Future<void> _cacheSymbolList(List<MarketItemEntity> marketItemList) async {
    var sharePref = await SharedPreferences.getInstance();
    List<String> _emptyMarketItemStrList = List();
    marketItemList.forEach((element) {
      var marketItemJsonStr = json.encode(MarketItemEntity(
        element.symbol,
        KLineEntity.fromCustom(),
        base: element.base,
        quote: element.quote,
      ).toJson());
      _emptyMarketItemStrList.add(marketItemJsonStr);
    });
    await sharePref.setStringList(
      PrefsKey.CACHE_MARKET_ITEM_LIST,
      _emptyMarketItemStrList,
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
            'amount': double.parse(itemList[5].toString()),
            'vol': double.parse(itemList[5].toString()),
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

    try {
      int index;
      for (var i = 0; i < _marketItemList.length; i++) {
        var element = _marketItemList[i];
        // replace
        if (element.symbol == symbol) {
          index = i;
          break;
        }
      }

      if (index != null) {
        var lastElement = _marketItemList[index];
        var element = MarketItemEntity(
          lastElement.symbol,
          kLineDataList.first,
          base: lastElement.base,
          quote: lastElement.quote,
        );
        _marketItemList[index] = element;
      }

      // 使得ui刷新
      _marketItemList = _marketItemList.toList();
    } catch (e) {}
  }
}

enum SocketAspect { marketItemList }

class MarketInheritedModel extends InheritedModel<SocketAspect> {
  final List<MarketItemEntity> marketItemList;

  // final List<List<String>> tradeDetailList;

  const MarketInheritedModel({
    Key key,
    @required this.marketItemList,
    // @required this.tradeDetailList,
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

  // @deprecated
  // String getCurrentSymbolRealTimePrice() {
  //   if (tradeDetailList != null && tradeDetailList.length > 0) {
  //     var tradeDetail = tradeDetailList[0];
  //     Decimal tradeDecimal = Decimal.parse(tradeDetail[1]);
  //     return FormatUtil.truncateDecimalNum(tradeDecimal, 4);
  //   }
  //   return "0";
  // }
  //
  // //buy 为 true , sell 为 false
  // @deprecated
  // bool isBuyCurrentSymbolRealTimeDirection() {
  //   if (tradeDetailList != null && tradeDetailList.length > 0) {
  //     var tradeDetail = tradeDetailList[0];
  //     var direction = tradeDetail[3];
  //     return direction == "buy";
  //   }
  //   return true;
  // }

  double getRealTimePricePercent(String symbol) {
    try {
      var marketItem = getMarketItem(symbol);
      var realPercent = marketItem == null
          ? 0.0
          : (marketItem.kLineEntity.close - marketItem.kLineEntity.open) /
              (marketItem.kLineEntity.open);
      return realPercent;
    } catch (e) {
      return 0.0;
    }
  }

  double get24HourAmount(String symbol) {
    var marketItem = getMarketItem(symbol);
    var amount =
        marketItem == null ? 0.0 : (marketItem.kLineEntity?.amount ?? 0.0);
    return amount;
  }

  static MarketInheritedModel of(BuildContext context, {SocketAspect aspect}) {
    return InheritedModel.inheritFrom<MarketInheritedModel>(context,
        aspect: aspect);
  }

  @override
  bool updateShouldNotify(MarketInheritedModel old) {
    return marketItemList !=
        old.marketItemList; // || tradeDetailList != old.tradeDetailList;
  }

  @override
  bool updateShouldNotifyDependent(
    MarketInheritedModel old,
    Set<SocketAspect> dependencies,
  ) {
    return marketItemList != old.marketItemList &&
        dependencies.contains(SocketAspect.marketItemList);
    // ||
    // tradeDetailList != old.tradeDetailList && dependencies.contains(SocketAspect.tradeDetailList);
  }
}
