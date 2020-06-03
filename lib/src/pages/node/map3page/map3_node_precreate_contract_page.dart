import 'dart:io';
import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/model/node_provider_entity.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';

class Map3NodePreCreateContractPage extends StatefulWidget {
  final String contractId;

  Map3NodePreCreateContractPage(this.contractId);

  @override
  _Map3NodePreCreateContractState createState() => new _Map3NodePreCreateContractState();
}

class _Map3NodePreCreateContractState extends State<Map3NodePreCreateContractPage> {
  AllPageState currentState = LoadingState();
  NodeApi _nodeApi = NodeApi();
  ContractNodeItem _contractItem;
  List<NodeProviderEntity> _providerList = [];
  NodeItem _nodeItem;

  @override
  void initState() {
    getNetworkData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Map3节点介绍")),
      backgroundColor: Color(0xffF3F0F5),
      body: _pageView(context),
    );
  }

  void getNetworkData() async {
    try {
      var requestList =
          await Future.wait([_nodeApi.getContractItem(widget.contractId), _nodeApi.getNodeProviderList()]);
      _contractItem = requestList[0];
      _nodeItem = _contractItem.contract;

      _providerList = requestList[1];

      setState(() {
        currentState = null;
      });
    } catch (e) {
      setState(() {
        currentState = LoadFailState();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _pageView(BuildContext context) {
    if (currentState != null || _nodeItem == null) {
      return Scaffold(
        body: AllPageStateContainer(currentState, () {
          setState(() {
            currentState = LoadingState();
          });
          getNetworkData();
        }),
      );
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _nodeWidget(),
              SizedBox(
                height: 10,
                child: Container(
                  color: HexColor("#F4F4F4"),
                ),
              ),
              _tipsWidget(),
            ])),
          ),
          _confirmButtonWidget(),
        ],
      ),
    );
  }

  Widget _tipsWidget() {
    var _nodeWidget = Padding(
      padding: const EdgeInsets.only(right: 10, top: 10),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DefaultColors.color999,
            border: Border.all(color: DefaultColors.color999, width: 1.0)),
      ),
    );

    Widget _rowWidget(String title, {double top = 8}) {
      return Padding(
        padding: EdgeInsets.only(top: top),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _nodeWidget,
            Expanded(child: Text(title, style: TextStyle(height: 1.8, color: DefaultColors.color999, fontSize: 12))),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      //height: MediaQuery.of(context).size.height-50,
      padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8),
            child: Text("注意事项", style: TextStyle(color: HexColor("#333333"), fontSize: 16)),
          ),
          _rowWidget("创建7天内不可撤销", top: 0),
          _rowWidget("需要总抵押满100万才能正式启动，你至少需要20万的HYN作为首次抵押，剩余的份额需要其他抵押!者参加投入;你也可以一次性抵押100万即可启动节点"),
          _rowWidget("创建时可设置自动续约，当期满后节点自动尝试重新启动以获得更多奖励;你也可以在任何时候关闭或开启自动续约开关"),
        ],
      ),
    );
  }

  Widget _tipsWidget_old() {
    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;

    return Container(
      color: Colors.white,
      //height: MediaQuery.of(context).size.height-50,
      padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8),
            child: Text("注意事项", style: TextStyle(color: HexColor("#333333"), fontSize: 16)),
          ),
          Text(S.of(context).create_contract_only_one_hint, style: TextStyles.textC999S12),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(S.of(context).create_no_enough_hyn_start_fail, style: TextStyles.textC999S12),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(S.of(context).contract_create_cant_destroy, style: TextStyles.textC999S12),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(S.of(context).please_confirm_eth_gas_enough(walletName), style: TextStyles.textC999S12),
          ),
//                  Padding(
//                    padding: const EdgeInsets.only(top: 10.0, bottom: 10),
//                    child: Text(S.of(context).freeze_balance_reward_direct_push, style: TextStyles.textC999S12),
//                  ),
        ],
      ),
    );
  }

  Widget _confirmButtonWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 4.0,
          ),
        ],
      ),
      constraints: BoxConstraints.expand(height: 50),
      child: RaisedButton(
          textColor: Colors.white,
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColor)),
          child: Text("立即创建", style: TextStyle(fontSize: 16, color: Colors.white)),
          onPressed: () {
            Application.router
                .navigateTo(context, Routes.map3node_create_contract_page + "?contractId=${widget.contractId}");
          }),
    );
  }

  Widget _nodeWidget() {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          _nodeIntroductionWidget(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 2,
            ),
          ),
          _delegateCountWidget(),
          _nodeServerWidget(),
        ],
      ),
    );
  }

  Widget _delegateCountWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 16.0),
      child: Row(
        children: [1, 0.5, 2, 0.5, 3].map((value) {
          String title = "";
          String detail = "0";
          Color color = HexColor("#000000");

          switch (value) {
            case 1:
              title = "创建最低抵押";

              double tempMinTotal = double.parse(_nodeItem.minTotalDelegation) * _nodeItem.ownerMinDelegationRate;
              detail = FormatUtil.amountToString(tempMinTotal.toString());

              break;

            case 2:
              title = "年化奖励";
              detail = FormatUtil.formatPercent(_nodeItem.annualizedYield);
              color = HexColor("#FF4C3B");
              break;

            case 3:
              title = "管理费";
              detail = "1%-20%";
              break;

            default:
              return Container(
                height: 20,
                width: 1.0,
                color: HexColor("#000000").withOpacity(0.2),
              );
              break;
          }

          TextStyle style = TextStyle(fontSize: 19, color: color, fontWeight: FontWeight.w600);

          return Expanded(
            child: Center(
                child: Column(
              children: <Widget>[
                Text(detail, style: style),
                Container(
                  height: 4,
                ),
                Text(title, style: TextStyles.textC333S11),
              ],
            )),
          );
        }).toList(),
      ),
    );
  }

  Widget _nodeIntroductionWidget() {
    var nodeItem = _nodeItem;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        //mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Image.asset(
            "res/drawable/ic_map3_node_item_2.png",
            width: 62,
            height: 63,
            fit: BoxFit.cover,
          ),
          SizedBox(
            width: 12,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(child: Text(nodeItem.name, style: TextStyle(fontWeight: FontWeight.bold))),
                    InkWell(
                      child: Text("节点细则", style: TextStyle(fontSize: 14, color: HexColor("#1F81FF"))),
                      onTap: () {
                        String webUrl =
                        FluroConvertUtils.fluroCnParamsEncode(
                            "http://baidu.com");
                        String webTitle =
                        FluroConvertUtils.fluroCnParamsEncode(
                            "节点细则");
                        Application.router.navigateTo(
                            context,
                            Routes.toolspage_webview_page +
                                '?initUrl=$webUrl&title=$webTitle');
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                          "启动所需" +
                              " ${FormatUtil.formatTenThousandNoUnit(nodeItem.minTotalDelegation)}" +
                              S.of(context).ten_thousand,
                          style: TextStyles.textC99000000S13,
                          maxLines: 1,
                          softWrap: true),
                      Text("  |  ", style: TextStyle(fontSize: 12, color: HexColor("000000").withOpacity(0.2))),
                      Text(S.of(context).n_day(nodeItem.duration.toString()), style: TextStyles.textC99000000S13)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nodeServerWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [1, 2].map((value) {
          var title = "";
          var detail = "";
          switch (value) {
            case 1:
              title = S.of(context).service_provider;
              detail = _providerList.first.name;
              break;

            case 2:
              title = "服务片区";
              detail = "根据云所在链路位置就近服务";
              break;

            default:
              return SizedBox(
                height: 8,
              );
              break;
          }

          return Padding(
            padding: EdgeInsets.only(top: value == 1 ? 0 : 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(width: 80, child: Text(title, style: TextStyle(fontSize: 14, color: HexColor("#92979A")))),
                Expanded(
                    child: Text(
                  detail,
                  style: TextStyle(fontSize: 15, color: HexColor("#333333")),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ))
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
