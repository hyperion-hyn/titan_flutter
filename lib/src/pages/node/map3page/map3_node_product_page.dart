import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/map3page/map3_node_create_contract_page.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/model/node_product_page_vo.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/route_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/data/cache/memory_cache.dart';
import 'package:collection/collection.dart';

class Map3NodeProductPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Map3NodeProductState();
  }
}

class _Map3NodeProductState extends State<Map3NodeProductPage> {
  LoadDataBloc loadDataBloc = LoadDataBloc();
  NodeApi _nodeApi = NodeApi();
  List<NodeItem> nodeList = MemoryCache.nodeProductPageData.nodeItemList;
  int currentPage = 0;

  @override
  void initState() {
    if (!MemoryCache.hasNodeProductPageData) {
      loadDataBloc.add(LoadingEvent());
    } else {
      getNetworkData();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(S.of(context).node_mortgage_contract)),
      body: _pageView(),
    );
  }

  Widget _pageView() {
    return Container(
      color: HexColor("#f5f5f5"),
      child: LoadDataContainer(
        bloc: loadDataBloc,
        onLoadData: () async {
          getNetworkData();
        },
        onRefresh: () async {
          getNetworkData();
        },
        onLoadingMore: () {
          getMoreNetworkData();
        },
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              return getMap3NodeProductItem(context, nodeList[index]);
            }, childCount: nodeList.length))
          ],
        ),
      ),
    );
  }

  void getNetworkData() async {
    try {
      var netData = await _nodeApi.getContractList(currentPage);
      if (!NodeProductPageVo(netData).isEqual(MemoryCache.nodeProductPageData)) {
        nodeList = netData;
        MemoryCache.nodeProductPageData = netData;
      }

      if (mounted) {
        setState(() {
          loadDataBloc.add(RefreshSuccessEvent());
        });
      }
    } catch (e) {
      loadDataBloc.add(LoadFailEvent());
    }
  }

  void getMoreNetworkData() async {
    try {
      currentPage = currentPage + 1;
      List<NodeItem> tempNodeList = await _nodeApi.getContractList(currentPage);
      if (tempNodeList.length > 0) {
        nodeList.addAll(tempNodeList);
        loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        loadDataBloc.add(LoadMoreEmptyEvent());
      }
      setState(() {});
    } catch (e) {
      loadDataBloc.add(LoadMoreFailEvent());
    }
  }

  @override
  void dispose() {
    loadDataBloc.close();
    super.dispose();
  }

  Widget getMap3NodeProductItem(BuildContext context, NodeItem nodeItem) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.only(left: 20.0, right: 19, top: 21, bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Image.asset(
                "res/drawable/ic_map3_node_item_contract.png",
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              SizedBox(
                width: 6,
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(child: Text("${nodeItem.nodeName}", style: TextStyle(fontWeight: FontWeight.bold)))
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                              S.of(context).highest +
                                  " ${FormatUtil.formatTenThousandNoUnit(nodeItem.minTotalDelegation)}" +
                                  S.of(context).ten_thousand,
                              style: TextStyles.textC99000000S13,
                              maxLines: 1,
                              softWrap: true),
                          Text("  |  ", style: TextStyles.textC9b9b9bS12),
                          Text(S.of(context).n_day(nodeItem.duration.toString()), style: TextStyles.textC99000000S13)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  Text("${FormatUtil.formatPercent(nodeItem.annualizedYield)}", style: TextStyles.textCff4c3bS20),
                  Text(S.of(context).annualized_rewards, style: TextStyles.textC99000000S13)
                ],
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 9, bottom: 9),
            child: Divider(height: 1, color: DefaultColors.color2277869e),
          ),
          Row(
            children: <Widget>[
              Expanded(child: Text("")),
              SizedBox(
                height: 24,
                width: 92,
                child: FlatButton(
                  color: DefaultColors.colorffdb58,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  onPressed: () async {
                    var walletList = await WalletUtil.scanWallets();
                    if (walletList.length == 0) {
                      Application.router.navigateTo(context, Routes.map3node_create_wallet);
                    } else {
                      await Application.router
                          .navigateTo(context, Routes.map3node_create_contract_page + "?contractId=${nodeItem.id}");
                    }
                  },
                  child: Text(S.of(context).create_contract, style: TextStyles.textC906b00S13),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
