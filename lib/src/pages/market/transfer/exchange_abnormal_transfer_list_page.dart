import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/model/asset_history.dart';
import 'package:titan/src/pages/market/order/entity/order.dart';
import 'package:titan/src/pages/mine/about_me_page.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/fix_dex_account_dialog.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

import '../../../global.dart';
import 'exchange_transfer_history_detail_page.dart';

class ExchangeAbnormalTransferListPage extends StatefulWidget {
  final String address;

  ExchangeAbnormalTransferListPage(this.address);

  @override
  State<StatefulWidget> createState() {
    return ExchangeAbnormalTransferListPageState();
  }
}

class ExchangeAbnormalTransferListPageState
    extends State<ExchangeAbnormalTransferListPage>
    with AutomaticKeepAliveClientMixin {
  List<AssetHistory> _errorTransferHistoryList = List();
  AbnormalTransferHistory _abnormalTransferHistory = AbnormalTransferHistory();
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  ExchangeApi _exchangeApi = ExchangeApi();

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
          S.of(context).dex_account_error,
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
          enablePullUp: false,
          onLoadData: () async {
            _refresh();
          },
          onRefresh: () async {
            _refresh();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _fixAccount(),
              ),
              _errorTransferList()
            ],
          ),
        ),
      ),
    );
  }

  _fixAccount() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'res/drawable/error_rounded.png',
            width: 60,
            height: 60,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(S.of(context).dex_account_data_abnormal),
          ),
          SizedBox(
            height: 16,
          ),
          Align(
            alignment: Alignment.center,
            child: ClickOvalButton(S.of(context).dex_fix_account, () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return FixDexAccountDialog(_abnormalTransferHistory);
                  });
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              S.of(context).dex_fix_account_hint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: DefaultColors.color999,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AboutMePage()));
            },
            child: Text(
              S.of(context).dex_fix_account_contact_us,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _errorTransferList() {
    if (_errorTransferHistoryList.isEmpty) {
      return SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 32,
            ),
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
      );
    } else {
      return SliverList(
          delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _transferHistoryItem(
            _errorTransferHistoryList[index]..status = '9',
          );
        },
        childCount: _errorTransferHistoryList.length,
      ));
    }
  }

  _refresh() async {
    ///clear list before refresh
    _errorTransferHistoryList.clear();
    try {
      AbnormalTransferHistory result =
          await _exchangeApi.getAbnormalTransferHistory(
        widget.address,
      );

      _abnormalTransferHistory = result;

      if (result.list.length > 0) {
        _errorTransferHistoryList.addAll(result.list);
      }
    } catch (e) {}

    if (mounted) setState(() {});
    _loadDataBloc.add(RefreshSuccessEvent());
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
                Row(
                  children: [
                    Text(
                      assetHistory.getTypeText(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                      ),
                      child: Image.asset(
                        'res/drawable/error_rounded.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ],
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
// TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
