import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
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
  ExchangeApi _exchangeApi = ExchangeApi();

  int _currentPage = 1;
  int _size = 30;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refresh();
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
      enablePullUp: _orderDetailList.isNotEmpty,
      onLoadData: () async {},
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
    if (_orderDetailList.isEmpty) {
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
      return ListView.builder(
        itemCount: _orderDetailList.length,
        itemBuilder: (ctx, index) => OrderDetailItem(
          _orderDetailList[index],
        ),
      );
    }
  }

  _refresh() async {
    _currentPage = 1;

    ///clear list before refresh
    _orderDetailList.clear();

    List<OrderDetail> resultList = await _exchangeApi.getOrderDetailList(
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
    try {
      List<OrderDetail> resultList = await _exchangeApi.getOrderDetailList(
        widget.market,
        _currentPage + 1,
        _size,
      );
      if (resultList != null) {
        _orderDetailList.addAll(resultList);
        _currentPage++;
      }

      if (mounted) setState(() {});
      _loadDataBloc.add(LoadingMoreSuccessEvent());
      _refreshController.loadComplete();
    } on HttpResponseCodeNotSuccess catch (e) {}
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
