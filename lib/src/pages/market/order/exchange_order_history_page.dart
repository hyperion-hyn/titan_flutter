import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
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
  RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  LoadDataBloc _loadDataBloc = LoadDataBloc();

  int _currentPage = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadMore();
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
        _loadMore();
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

  void _refresh() async {
    _currentPage = 0;
    await Future.delayed(Duration(milliseconds: 1000));

    ///clear list before refresh
    _orders.clear();
    _orders.addAll(
      (List.generate(
        5,
        (index) => Order.fromJson({}),
      )),
    );
    _loadDataBloc.add(RefreshSuccessEvent());
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  _loadMore() async {
    _currentPage++;
    try {} catch (e) {
      logger.e(e.toString());
    }
    await Future.delayed(Duration(milliseconds: 1000));
    _orders.addAll((List.generate(
        10, (index) => Order.fromJson({}))));
    _loadDataBloc.add(LoadingMoreSuccessEvent());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
