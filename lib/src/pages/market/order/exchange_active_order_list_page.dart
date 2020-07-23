import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/pages/market/order/entity/order.dart';

import '../../../global.dart';
import 'item_order.dart';

class ExchangeActiveOrderListPage extends StatefulWidget {
  final String market;

  ExchangeActiveOrderListPage(this.market);

  @override
  State<StatefulWidget> createState() {
    return ExchangeActiveOrderListPageState();
  }
}

class ExchangeActiveOrderListPageState
    extends State<ExchangeActiveOrderListPage>
    with AutomaticKeepAliveClientMixin {
  List<Order> _activeOrders = List();
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
        itemCount: _activeOrders.length,
        itemBuilder: (ctx, index) => OrderItem(_activeOrders[index]),
      ),
    );
  }

  void _refresh() async {
    _currentPage = 0;
    await Future.delayed(Duration(milliseconds: 1000));

    ///clear list before refresh
    _activeOrders.clear();
    _activeOrders.addAll(
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
    _activeOrders.addAll((List.generate(10, (index) => Order.fromJson({}))));
    _loadDataBloc.add(LoadingMoreSuccessEvent());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
