import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
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
  RefreshController _refreshController = RefreshController(
    initialRefresh: true,
  );

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
      onLoadData: () async {
        _refresh();
      },
      onRefresh: () async {
        _refresh();
      },
      onLoadingMore: () {
        _loadMore();
      },
      child: ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (ctx, index) => OrderItem(_orders[index]),
      ),
    );
  }

  _refresh() async {
    _currentPage = 1;

    ///clear list before refresh
    _orders.clear();
    List<Order> resultList =
        await ExchangeInheritedModel.of(context).exchangeApi.getOrderList(
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
    _refreshController.refreshCompleted();
  }

  _loadMore() async {
    _currentPage++;
    List<Order> resultList =
        await ExchangeInheritedModel.of(context).exchangeApi.getOrderList(
              widget.market,
              _currentPage,
              _size,
              _method,
            );
    print('[ExchangeOrderHistoryPage] _loadMore: resultList $resultList');
    if (resultList != null) {
      _orders.addAll(resultList);
    }
    if (mounted) setState(() {});
    _loadDataBloc.add(LoadingMoreSuccessEvent());
    _refreshController.loadComplete();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
