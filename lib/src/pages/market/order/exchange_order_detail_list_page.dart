import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/pages/market/order/entity/order_detail.dart';

import '../../../global.dart';
import 'item_order.dart';
import 'item_order_detail.dart';

class ExchangeOrderDetailListPage extends StatefulWidget {
  final String market;

  ExchangeOrderDetailListPage(this.market);

  @override
  State<StatefulWidget> createState() {
    return ExchangeOrderDetailListPageState();
  }
}

class ExchangeOrderDetailListPageState
    extends State<ExchangeOrderDetailListPage>
    with AutomaticKeepAliveClientMixin {
  List<OrderDetail> _orderDetailList = List();
  RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  LoadDataBloc _loadDataBloc = LoadDataBloc();

  int _currentPage = 1;
  int _size = 30;

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
        itemCount: _orderDetailList.length,
        itemBuilder: (ctx, index) => OrderDetailItem(
          _orderDetailList[index],
          widget.market,
        ),
      ),
    );
  }

  _refresh() async {
    _currentPage = 1;

    ///clear list before refresh
    _orderDetailList.clear();

    List<OrderDetail> resultList =
        await ExchangeInheritedModel.of(context).exchangeApi.getOrderDetailList(
              widget.market,
              _currentPage,
              _size,
            );
    _orderDetailList.addAll(resultList);
    _loadDataBloc.add(RefreshSuccessEvent());
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  _loadMore() async {
    _currentPage++;
    List<OrderDetail> resultList =
        await ExchangeInheritedModel.of(context).exchangeApi.getOrderDetailList(
              widget.market,
              _currentPage,
              _size,
            );
    _orderDetailList.addAll(resultList);
    _loadDataBloc.add(LoadingMoreSuccessEvent());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
