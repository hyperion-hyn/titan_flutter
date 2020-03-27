import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/map3page/map3_node_create_join_contract_page.dart';
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
                    double topValue = (index == 0) ? 10 : 0;
                    bool hasRemind = (index == 3) ? true : false;
                    return Card(
                        color: Colors.white,
                        margin: EdgeInsets.only(left: 5.0, right: 5, bottom: 5,  top:topValue),
                        child: getMap3NodeProductItem(context, hasRemind: hasRemind));
              }, childCount: 30))
            ],
          ),
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

Widget getMap3NodeProductItem(BuildContext context,{hasRemind = false,showButton = true}) {
  return Padding(
    padding: EdgeInsets.only(left: 10.0, right: 10, top: 10, bottom: 10),
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
                fit:BoxFit.cover,
              ),
            ),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("MAP3节点（V0.8）",
                              style: TextStyles.textC333S14bold),
                          SizedBox(height: 5,),
                          Text("启动共需1,000,000HYN",
                              style: TextStyles.textC333S14)
                        ],
                      ),
                    ),
                  ),
                  if(showButton)
                    MaterialButton(
                    height: 30,
                    color: Colors.white,
                    onPressed: () async {
                      var walletList = await WalletUtil.scanWallets();
                      if(walletList.length == 0){
                        Application.router.navigateTo(context, Routes.map3node_create_wallet);
                      }else{
                        Application.router.navigateTo(context, Routes.map3node_create_join_contract_page
                            + "?pageType=${Map3NodeCreateJoinContractPage.CONTRACT_PAGE_TYPE_CREATE}"
                            + "&entryRouteName=${Uri.encodeComponent(Routes.map3node_product_list)}");
                      }
                    },
                    child: Text("创建合约", style: TextStyles.textC26ac29S12),
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
            ),
            Expanded(
              child: Center(
                  child: Column(
                    children: <Widget>[
                      Text("创建最低投入", style: TextStyles.textC9b9b9bS12),
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
  );
}
