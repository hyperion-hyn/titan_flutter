import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_introduce_entity.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/node_provider_entity.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'map3_node_public_widget.dart';

class Map3NodeIntroductionPage extends StatefulWidget {
  Map3NodeIntroductionPage();

  @override
  _Map3NodeIntroductionState createState() => new _Map3NodeIntroductionState();
}

class _Map3NodeIntroductionState extends State<Map3NodeIntroductionPage> {
  AllPageState currentState = LoadingState();
  AtlasApi _atlasApi = AtlasApi();
  NodeApi _nodeApi = NodeApi();
  Map3IntroduceEntity _entity;
  List<NodeProviderEntity> _providerList = [];

  @override
  void initState() {
    super.initState();

    getNetworkData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: 'Map3节点介绍',
      ),
      backgroundColor: Color(0xffF3F0F5),
      body: _pageView(context),
    );
  }

  void getNetworkData() async {
    try {
      var requestList = await Future.wait([
        _atlasApi.getMap3Introduce(),
        _nodeApi.getNodeProviderList(),
      ]);

      _entity = requestList[0];
      _providerList = requestList[1];

      setState(() {
        currentState = null;
      });
    } catch (e) {
      print(e);
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
    if (currentState != null || _entity == null) {
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
    var onTap = (String subTitle) {
      if (subTitle.isEmpty) {
        return;
      }
      AtlasApi.goToAtlasMap3HelpPage(context);
    };

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
          rowTipsItem("创建7天内不可撤销", top: 0),
          rowTipsItem(
              "需要总抵押满${_entity?.startMin ?? 0}才能正式启动，你至少需要${(double.parse(_entity?.startMin ?? 0)) * (double.parse(_entity?.feeMin ?? 0))}的HYN作为首次抵押，剩余的份额需要其他抵押者参加投入;你也可以一次性抵押${_entity?.startMin ?? 0}即可启动节点"),
          rowTipsItem("创建后默认是到期自动续约以获得等多奖励；你也可以在到期前7-14天关闭或开启自动续约开关"),
          rowTipsItem(
            "节点收益来自map3服务工作量证明和参与atlas权益共识出块证明，查看",
            subTitle: "收益详细介绍",
            onTap: () {
              onTap("收益详细介绍");
            },
          ),
          rowTipsItem(
            "如果节点总抵押金额过大，你可以裂变节点以获得更优的收益方案，查看",
            subTitle: "扩容详细介绍",
            onTap: () {
              onTap("扩容详细介绍");
            },
          ),
        ],
      ),
    );
  }

  Widget _confirmButtonWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Center(
        child: ClickOvalButton(
          "立即创建",
          () {
            Application.router.navigateTo(context, Routes.map3node_create_contract_page + "?contractId=2");
          },
          height: 46,
          width: MediaQuery.of(context).size.width - 37 * 2,
          fontSize: 18,
        ),
      ),
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
              height: 0.5,
            ),
          ),
          _delegateCountWidget(),
          _nodeServerWidget(),
        ],
      ),
    );
  }

  Widget _delegateCountWidget() {
    var detail = FormatUtil.formatPrice(double.parse(_entity?.createMin ?? "0"));
    var feeMin = (100 * double.parse(_entity?.feeMin ?? "10")).toInt();
    var feeMax = (100 * double.parse(_entity?.feeMax ?? "20")).toInt();
    var fee = "$feeMin%-$feeMax%";
    var day = "${_entity?.days ?? 180}天";
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 16.0),
      child: profitListLightWidget(
        [
          {"创建最低抵押": detail},
          {"管理费": fee},
          {"合约周期": day}
        ],
      ),
    );
  }

  Widget _nodeIntroductionWidget() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        //mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Image.asset(
            "res/drawable/ic_map3_node_item_2.png",
            width: 62,
            height: 62,
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
                    Expanded(child: Text(_entity?.name ?? "", style: TextStyle(fontWeight: FontWeight.bold))),
                    InkWell(
                      child: Text("详细介绍", style: TextStyle(fontSize: 14, color: HexColor("#1F81FF"))),
                      onTap: () {
                        AtlasApi.goToAtlasMap3HelpPage(context);
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          "启动所需" +
                              " ${FormatUtil.formatTenThousandNoUnit(_entity?.startMin?.toString() ?? "0")}" +
                              S.of(context).ten_thousand,
                          style: TextStyles.textC99000000S13,
                          maxLines: 1,
                          softWrap: true),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(" (HYN) ", style: TextStyle(fontSize: 10, color: HexColor("#999999"))),
                      ),
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
