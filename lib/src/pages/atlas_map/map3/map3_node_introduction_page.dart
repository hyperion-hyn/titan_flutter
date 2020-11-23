import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/load_data_bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/load_data_event.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
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
  NodeApi _nodeApi = NodeApi();
  Map3IntroduceEntity _introduceEntity;
  List<NodeProviderEntity> _providerList = [];
  LoadDataBloc _loadDataBloc = LoadDataBloc();

  @override
  void initState() {
    super.initState();

    getNetworkData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).map3_introduce_title,
      ),
      backgroundColor: Color(0xffF3F0F5),
      body: _pageView(context),
    );
  }

  void getNetworkData() async {
    try {
      var requestList = await Future.wait([
        AtlasApi.getIntroduceEntity(),
        _nodeApi.getNodeProviderList(),
      ]);

      _introduceEntity = requestList[0];
      _providerList = requestList[1];

      setState(() {
        _loadDataBloc.add(RefreshSuccessEvent());
        currentState = null;
      });
    } catch (e) {
      print(e);
      setState(() {
        _loadDataBloc.add(RefreshFailEvent());

        currentState = LoadFailState();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _pageView(BuildContext context) {
    if (currentState != null || _introduceEntity == null) {
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
            child: LoadDataContainer(
              bloc: _loadDataBloc,
              enablePullUp: false,
              onRefresh: getNetworkData,
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

    var startMinValue = double.parse(_introduceEntity?.startMin ?? "0");
    var startMin = FormatUtil.formatPrice(startMinValue);
    var createMin =
        FormatUtil.formatPrice(double.parse(_introduceEntity?.createMin ?? 0));

    var feeMax = (100 * double.parse(_introduceEntity?.feeMax ?? "20")).toInt();
    var amount =
        " ${FormatUtil.formatTenThousandNoUnit(startMinValue.toString())}" +
            S.of(context).ten_thousand;
    var rateTips = S.of(context).map3_manage_fee_rule(amount, feeMax);

    return Container(
      color: Colors.white,
      //height: MediaQuery.of(context).size.height-50,
      padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8),
            child: Text(S.of(context).precautions,
                style: TextStyle(color: HexColor("#333333"), fontSize: 16)),
          ),
          rowTipsItem(S.of(context).cant_cancel_within_7_epoch, top: 0),
          rowTipsItem(
              S.of(context).activate_node_rule_total_staking(startMin, createMin)),
          rowTipsItem(S.of(context).map3_auto_renew_hint),
          rowTipsItem(
            "${S.of(context).reward_comes_from_pow_and_pos}，${S.of(context).check}",
            subTitle: S.of(context).reward_detailed_introduction,
            onTap: () {
              onTap(S.of(context).reward_detailed_introduction);
            },
          ),
          //rowTipsItem(rateTips),
          /*rowTipsItem(
            "如果节点总抵押金额过大，你可以裂变节点以获得更优的收益方案，查看",
            subTitle: "扩容详细介绍",
            onTap: () {
              onTap("扩容详细介绍");
            },
          ),*/
        ],
      ),
    );
  }

  Widget _confirmButtonWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Center(
        child: ClickOvalButton(
          S.of(context).create_now,
          () {
            Application.router.navigateTo(context,
                Routes.map3node_create_contract_page + "?contractId=2");
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
    var detail = FormatUtil.formatPrice(
        double.parse(_introduceEntity?.createMin ?? "0"));
    // var feeMin = (100 * double.parse(_introduceEntity?.feeMin ?? "10")).toInt();
    // var feeMax = (100 * double.parse(_introduceEntity?.feeMax ?? "20")).toInt();
    var fee = '${(100 * double.parse(_introduceEntity?.feeFixed ?? "10")).toInt()}%'; // "$feeMin%-$feeMax%";
    var day = "${_introduceEntity?.days ?? 180}${S.of(context).epoch}";
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 16.0, left: 14),
      child: profitListLightWidget(
        [
          {S.of(context).map3_create_min_staking: detail},
          {S.of(context).manage_fee: fee},
          {S.of(context).contract_period: day}
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
                    Expanded(
                        child: Text(_introduceEntity?.name ?? "",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    InkWell(
                      child: Text(S.of(context).detailed_introduction,
                          style: TextStyle(
                              fontSize: 14, color: HexColor("#1F81FF"))),
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
                          S.of(context).active_still_need +
                              " ${FormatUtil.formatTenThousandNoUnit(_introduceEntity?.startMin?.toString() ?? "0")}" +
                              S.of(context).ten_thousand,
                          style: TextStyles.textC99000000S13,
                          maxLines: 1,
                          softWrap: true),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(" (HYN) ",
                            style: TextStyle(
                                fontSize: 10, color: HexColor("#999999"))),
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
              detail = _providerList?.first?.name ?? S.of(context).amazon_cloud;
              break;

            case 2:
              title = S.of(context).service_area;
              detail = S.of(context).service_according_location;
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
                Container(
                    width: 80,
                    child: Text(title,
                        style: TextStyle(
                            fontSize: 14, color: HexColor("#92979A")))),
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
