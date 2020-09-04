import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/order/entity/order.dart';

import '../../../global.dart';
import 'item_order.dart';

class ExchangeOrderHistoryPage extends StatefulWidget {
  final String market;

  ExchangeOrderHistoryPage(this.market);

  @override
  State<StatefulWidget> createState() {
    return ExchangeOrderHistoryPageState();
  }
}

class ExchangeOrderHistoryPageState extends State<ExchangeOrderHistoryPage>
    with AutomaticKeepAliveClientMixin {
  List<Order> _orders = List();
  LoadDataBloc _loadDataBloc = LoadDataBloc();

  ExchangeApi _exchangeApi = ExchangeApi();

  int _currentPage = 1;
  int _size = 30;
  String _method = 'history';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDataBloc.add(LoadingEvent());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _loadDataBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return LoadDataContainer(
      bloc: _loadDataBloc,
      enablePullUp: _orders.isNotEmpty,
      onLoadData: () async {
        _refresh();
      },
      onRefresh: () async {
        _refresh();
      },
      onLoadingMore: () {
        _loadMore();
      },
      child: _content(),
    );
  }

  _content() {
    if (_orders.isEmpty) {
      return Center(
        child: Container(
          height: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'res/drawable/ic_empty_list.png',
                height: 80,
                width: 80,
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                '暂无记录',
                style: TextStyle(
                  color: HexColor('#FF999999'),
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return OrderItem(_orders[index]);
              },
              childCount: _orders.length,
            ),
          ),
        ],
      );
    }
  }

  _refresh() async {
    _currentPage = 1;

    ///clear list before refresh
    _orders.clear();

    try {
      List<Order> resultList = await _exchangeApi.getOrderList(
        widget.market,
        _currentPage,
        _size,
        _method,
      );
      print('[ExchangeOrderHistoryPage] _refresh: resultList $resultList');
      if (resultList != null) {
        _orders.addAll(resultList);
      }

      if (mounted) setState(() {});
      _loadDataBloc.add(RefreshSuccessEvent());
    } catch (e) {
      _loadDataBloc.add(RefreshSuccessEvent());
    }
  }

  _loadMore() async {
    try {
      List<Order> resultList = await _exchangeApi.getOrderList(
        widget.market,
        _currentPage + 1,
        _size,
        _method,
      );
      if (resultList != null) {
        _orders.addAll(resultList);
        _currentPage++;
      }
      if (mounted) setState(() {});
      _loadDataBloc.add(LoadingMoreSuccessEvent());
    } catch (e) {
      _loadDataBloc.add(LoadingMoreSuccessEvent());
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
