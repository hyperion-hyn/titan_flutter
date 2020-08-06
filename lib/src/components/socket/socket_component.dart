import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_k_chart/entity/k_line_entity.dart';
import 'package:titan/src/components/socket/bloc/bloc.dart';
import 'package:titan/src/components/socket/socket_config.dart';
import 'package:titan/src/pages/market/entity/market_item_entity.dart';
import 'package:titan/src/pages/market/exchange/exchange_page.dart';
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
  /*final IOWebSocketChannel socketChannel = IOWebSocketChannel.connect(
    'wss://api.huobi.pro/ws',
  );*/

  IOWebSocketChannel _socketChannel;

  SocketBloc _bloc;
  List<MarketItemEntity> _marketItemList;

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

      _bloc.add(ReceivedDataEvent(data: data));
    }, onDone: () {
      print('[WS] Done!');

      _reconnectWS();
    }, onError: (e) {
      // e is :WebSocketChannelException
      print('[WS] Error, e:$e');
    });

    // 心跳，预防一分钟没有消息，自动断开链接。
    Timer.periodic(Duration(seconds: 30), (t) {
      _bloc.add(HeartEvent());
    });
  }

  _initBloc() {
    _bloc = BlocProvider.of<SocketBloc>(context);
    _bloc.setSocketChannel(_socketChannel);
  }

  _initData() {
    _bloc.add(MarketSymbolEvent());
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
        }
      },
      child: BlocBuilder<SocketBloc, SocketState>(
        builder: (context, state) {
          return MarketInheritedModel(
            marketItemList: _marketItemList,
            child: widget.child,
          );
        },
      ),
    );
  }

  _updateMarketItemList(dynamic data,
      {bool isReplace = true, String symbol = ''}) {
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
            'amount': 0,
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
    _marketItemList.forEach((element) {
      if (element.symbol == symbol) {
        _isNewSymbol = false;
        element = MarketItemEntity(
          symbol,
          kLineDataList.last,
          symbolName: element.symbolName,
        );
      }
    });
    print('_updateQuoteItemList: isNewSymbol: $_isNewSymbol');
    if (_isNewSymbol) {
      _marketItemList.add(MarketItemEntity(symbol, kLineDataList.last));
    }
  }
}

class MarketInheritedModel extends InheritedModel<String> {
  final List<MarketItemEntity> marketItemList;

  const MarketInheritedModel({
    Key key,
    @required this.marketItemList,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(MarketInheritedModel oldWidget) {
    return true;
  }

  static MarketInheritedModel of(BuildContext context) {
    return InheritedModel.inheritFrom<MarketInheritedModel>(
      context,
    );
  }

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

  double getRealTimePricePercent(String symbol) {
    var marketItem = getMarketItem(symbol);
    var realPercent = marketItem == null
        ? 0.0
        : ((marketItem.kLineEntity?.close ?? 0.0 - marketItem.kLineEntity?.open) /
                marketItem.kLineEntity?.open ??
            1.0);
    return realPercent;
  }

  double get24HourAmount(String symbol) {
    var marketItem = getMarketItem(symbol);
    var amount =
        marketItem == null ? 0.0 : (marketItem.kLineEntity?.amount ?? 0.0);
    return amount;
  }

  @override
  bool updateShouldNotifyDependent(
    MarketInheritedModel old,
    Set<String> dependencies,
  ) {
    return marketItemList != old.marketItemList &&
        dependencies.contains('ExchangeModel');
  }
}
