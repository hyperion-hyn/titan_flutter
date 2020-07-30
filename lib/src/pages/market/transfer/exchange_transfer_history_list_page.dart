import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/model/asset_history.dart';
import 'package:titan/src/pages/market/order/entity/order.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';

import '../../../global.dart';
import 'exchange_transfer_history_detail_page.dart';

class ExchangeTransferHistoryListPage extends StatefulWidget {
  final String type;

  ExchangeTransferHistoryListPage(this.type);

  @override
  State<StatefulWidget> createState() {
    return ExchangeTransferHistoryListPageState();
  }
}

class ExchangeTransferHistoryListPageState
    extends State<ExchangeTransferHistoryListPage>
    with AutomaticKeepAliveClientMixin {
  List<AssetHistory> _transferHistoryList = List();
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  RefreshController _refreshController = RefreshController(
    initialRefresh: true,
  );
  ExchangeApi _exchangeApi = ExchangeApi();
  int _currentPage = 1;
  int _size = 20;
  String _action = 'all';

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          '划转记录',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
      body: LoadDataContainer(
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
          itemCount: _transferHistoryList.length,
          itemBuilder: (ctx, index) =>
              _transferHistoryItem(_transferHistoryList[index]),
        ),
      ),
    );
  }

  _refresh() async {
    _currentPage = 1;

    ///clear list before refresh
    _transferHistoryList.clear();
    List<AssetHistory> resultList =
        await _exchangeApi.getAccountHistory(
              widget.type,
              _currentPage,
              _size,
              _action,
            );
    if (resultList != null) {
      _transferHistoryList.addAll(resultList);
    }

    if (mounted) setState(() {});
    _loadDataBloc.add(RefreshSuccessEvent());
    _refreshController.refreshCompleted();
  }

  _loadMore() async {
    _currentPage++;
    List<AssetHistory> resultList =
        await _exchangeApi.getAccountHistory(
              widget.type,
              _currentPage,
              _size,
              _action,
            );
    if (resultList != null) {
      _transferHistoryList.addAll(resultList);
    }
    if (mounted) setState(() {});
    _loadDataBloc.add(LoadingMoreSuccessEvent());
    _refreshController.loadComplete();
  }

  _transferHistoryItem(AssetHistory assetHistory) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ExchangeTransferHistoryDetailPage(
                      assetHistory,
                    )));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '交易账户到钱包',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '数量(${assetHistory.type})',
                            style: TextStyle(
                              color: DefaultColors.color999,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            "${assetHistory.balance}",
                            style: TextStyle(
                                color: DefaultColors.color333,
                                fontWeight: FontWeight.w500,
                                fontSize: 12),
                          ),
                        ],
                      ),
                      Spacer()
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '手续费',
                      style: TextStyle(
                        color: DefaultColors.color999,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      '${assetHistory.fee})',
                      style: TextStyle(
                        color: DefaultColors.color333,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '时间',
                      style: TextStyle(
                        color: DefaultColors.color999,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Row(
                      children: <Widget>[
                        Spacer(),
                        Text(
                          FormatUtil.formatMarketOrderDate(
                            assetHistory.ctime,
                          ),
                          style: TextStyle(
                            color: DefaultColors.color333,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
