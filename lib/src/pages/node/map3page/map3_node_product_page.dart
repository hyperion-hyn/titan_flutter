import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';

class Map3NodeProductPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Map3NodeProductState();
  }
}

class _Map3NodeProductState extends State<Map3NodeProductPage> {
  LoadDataBloc loadDataBloc = LoadDataBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Map3节点抵押合约")),
      body: Container(
        color: HexColor("#f5f5f5"),
        child: LoadDataContainer(
          bloc: loadDataBloc,
          onRefresh: () async {},
          child: CustomScrollView(
            slivers: <Widget>[
              SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                return _getMap3NodeProductItem(context, index);
              }, childCount: 30))
            ],
          ),
        ),
      ),
    );
  }

  Widget _getMap3NodeProductItem(BuildContext context,int index) {
    double topValue = (index == 0) ? 10 : 0;
    bool hasRemind = (index == 3) ? true : false;
    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(left: 5.0, right: 5, bottom: 5,  top:topValue),
      child: Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10, top: 5, bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Image.asset(
                    "res/drawable/ic_map3_node_item.png",
                    width: 50,
                    height: 50,
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                              child: Text("MAP3节点（V0.8）",
                                  style: TextStyles.textC333S14)),
                          MaterialButton(
                            height: 30,
                            color: Colors.white,
                            onPressed: () async {
                              var walletList = await WalletUtil.scanWallets();
                              Application.router.navigateTo(context, Routes.map3node_product_list);
                            },
                            child: Text("创建合约", style: TextStyles.textC26ac29S12),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text("启动共需1，000，000HYN",
                            style: TextStyles.textC333S14),
                      )
                    ],
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Center(
                      child: Column(
                    children: <Widget>[
                      Text("期满年化奖励", style: TextStyles.textC9b9b9bS12),
                      Text("8.9%", style: TextStyles.textC333S14)
                    ],
                  )),
                ),
                Expanded(
                  child: Center(
                      child: Column(
                    children: <Widget>[
                      Text("合约期限", style: TextStyles.textC9b9b9bS12),
                      Text("1月", style: TextStyles.textC333S14)
                    ],
                  )),
                ),
                Expanded(
                  child: Center(
                      child: Column(
                    children: <Widget>[
                      Text("管理费", style: TextStyles.textC9b9b9bS12),
                      Text("20%", style: TextStyles.textC333S14)
                    ],
                  )),
                )
              ],
            ),
            if(hasRemind)
              Padding(
              padding: const EdgeInsets.only(top:8.0),
              child: Text("注：合约生效满3个月后，即可提取50%奖励", style: TextStyles.textCf29a6eS12),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    loadDataBloc.close();
    super.dispose();
  }
}
