import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
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
  ExchangeApi _exchangeApi = ExchangeApi();
  int _currentPage = 1;
  int _size = 20;
  String _action = 'all';

  @override
  void initState() {
    super.initState();
    _loadDataBloc.add(LoadingEvent());
  }

  @override
  void dispose() {
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
          "${widget.type}${S.of(context).exchange_transfer_history}",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: LoadDataContainer(
          bloc: _loadDataBloc,
          enablePullUp: _transferHistoryList.isNotEmpty,
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
        ),
      ),
    );
  }

  _content() {
    if (_transferHistoryList.isEmpty) {
      return Column(
        children: <Widget>[
          Expanded(
            child: Center(
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
                      S.of(context).exchange_empty_list,
                      style: TextStyle(
                        color: HexColor('#FF999999'),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      );
    } else {
      return ListView.builder(
        itemCount: _transferHistoryList.length,
        itemBuilder: (ctx, index) =>
            _transferHistoryItem(_transferHistoryList[index]),
      );
    }
  }

  _refresh() async {
    _currentPage = 1;

    ///clear list before refresh
    _transferHistoryList.clear();
    try {
      List<AssetHistory> resultList = await _exchangeApi.getAccountHistory(
        widget.type,
        _currentPage,
        _size,
        _action,
      );

      if (resultList.length > 0) {
        _transferHistoryList.addAll(resultList);
      }
    } catch (e) {}

    if (mounted) setState(() {});
    _loadDataBloc.add(RefreshSuccessEvent());
  }

  _loadMore() async {
    try {
      List<AssetHistory> resultList = await _exchangeApi.getAccountHistory(
        widget.type,
        _currentPage + 1,
        _size,
        _action,
      );
      if (resultList.length > 0) {
        _currentPage++;
        _transferHistoryList.addAll(resultList);
      }
      _currentPage++;
    } catch (e) {}
    if (mounted) setState(() {});

    _loadDataBloc.add(LoadingMoreSuccessEvent());
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
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  assetHistory.getTypeText(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  '${S.of(context).exchange_amount}(${assetHistory.type})',
                                  style: TextStyle(
                                    color: DefaultColors.color999,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(
                                  height: 4.0,
                                ),
                                Text(
                                  "${Decimal.parse(assetHistory.balance)}",
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${S.of(context).exchange_network_fee}(${assetHistory.name == 'withdraw' ? assetHistory.type : 'ETH'})',
                            style: TextStyle(
                              color: DefaultColors.color999,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '${Decimal.parse(assetHistory.fee)}',
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
                            S.of(context).exchange_order_time,
                            style: TextStyle(
                              color: DefaultColors.color999,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            FormatUtil.formatUTCDateStr(assetHistory.ctime),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              color: DefaultColors.color333,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: DefaultColors.color999,
                        size: 12,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(height: 1),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
