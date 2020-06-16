import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/pages/market/order/api/api_orders.dart';

import '../../../global.dart';
import 'entity/order_entity.dart';
import 'item_order.dart';

class OpenOrdersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OpenOrdersPageState();
  }
}

class OpenOrdersPageState extends State<OpenOrdersPage>
    with AutomaticKeepAliveClientMixin {
  List<OrderEntity> _openOrders = List();
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
        itemCount: _openOrders.length,
        itemBuilder: (ctx, index) => OrderItem(_openOrders[index]),
      ),
    );
  }

  void _refresh() async {
    _currentPage = 0;
    await Future.delayed(Duration(milliseconds: 1000));

    ///clear list before refresh
    _openOrders.clear();
    _openOrders.addAll(
      (List.generate(
        5,
        (index) => OrderEntity()..type = ExchangeType.SELL,
      )),
    );
    _loadDataBloc.add(RefreshSuccessEvent());
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  _loadMore() async {
    _currentPage++;
    try {

    } catch (e) {
      logger.e(e.toString());
    }
    await Future.delayed(Duration(milliseconds: 1000));
    _openOrders.addAll((List.generate(
        10, (index) => OrderEntity()..type = ExchangeType.SELL)));
    _loadDataBloc.add(LoadingMoreSuccessEvent());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
