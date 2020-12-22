import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/pages/market/order/exchange_order_detail_list_page.dart';
import 'package:titan/src/pages/market/order/exchange_order_history_page.dart';
import 'package:titan/src/pages/market/order/item_order.dart';
import 'package:titan/src/pages/market/order/exchange_active_order_list_page.dart';

class ExchangeOrderManagementPage extends StatefulWidget {
  final String market;

  ExchangeOrderManagementPage(this.market);

  @override
  State<StatefulWidget> createState() {
    return _ExchangeOrderManagementPageState();
  }
}

class _ExchangeOrderManagementPageState
    extends State<ExchangeOrderManagementPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(initialIndex: 0, vsync: this, length: 3);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SafeArea(
          child: Scaffold(
            appBar: new PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: new Container(
                width: double.infinity,
                height: 50.0,
                child: Row(
                  children: <Widget>[
                    InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: TabBar(
                        isScrollable: true,
                        labelColor: HexColor('#FF228BA1'),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorColor: HexColor('#FF228BA1'),
                        indicatorWeight: 2,
                        indicatorPadding: EdgeInsets.only(
                          bottom: 2,
                          right: 12,
                          left: 12,
                        ),
                        unselectedLabelColor: HexColor("#FF333333"),
                        tabs: [
                          Tab(
                            child: Text(
                              S.of(context).exchange_order_list_active,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Tab(
                            child: Text(
                              S.of(context).exchange_order_list_history,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Tab(
                            child: Text(
                              S.of(context).exchange_order_list_detail,
                              style: TextStyle(fontSize: 14),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: TabBarView(
              children: [
                ExchangeActiveOrderListPage(widget.market),
                ExchangeOrderHistoryPage(widget.market),
                ExchangeOrderDetailListPage(widget.market),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
