import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';

import 'entity/order_entity.dart';
import 'item_order.dart';

class AllOrdersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AllOrdersPageState();
  }
}

class AllOrdersPageState extends State<AllOrdersPage>
    with AutomaticKeepAliveClientMixin {
  List<OrderEntity> _allOrders = List();
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
          itemCount: _allOrders.length,
          itemBuilder: (ctx, index) => OrderItem(_allOrders[index])),
    );
  }

  void _refresh() async {
    _currentPage = 0;
    await Future.delayed(Duration(milliseconds: 1000));

    ///clear list before refresh
    _allOrders.clear();
    _allOrders.addAll((List.generate(
      5,
      (index) => OrderEntity()..type = ExchangeType.SELL,
    )));
    _loadDataBloc.add(RefreshSuccessEvent());
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  _loadMore() async {
    _currentPage++;
    await Future.delayed(Duration(milliseconds: 1000));
    _allOrders.addAll((List.generate(
      10,
      (index) => OrderEntity()..type = ExchangeType.SELL,
    )));
    _loadDataBloc.add(LoadingMoreSuccessEvent());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
