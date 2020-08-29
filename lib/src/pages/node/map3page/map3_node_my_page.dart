import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/routes/routes.dart';
import 'map3_node_list_page.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class Map3NodeMyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Map3NodeMyState();
  }
}

class _Map3NodeMyState extends State<Map3NodeMyPage> with TickerProviderStateMixin {
  TabController _tabController;
  List<MyContractModel> _contractTypeModels;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_contractTypeModels?.isEmpty ?? true) {
      _contractTypeModels = [
        MyContractModel(S.of(context).my_initiated_map_contract, MyContractType.create),
        MyContractModel(S.of(context).my_join_map_contract, MyContractType.join)
      ];
      _tabController = TabController(length: _contractTypeModels.length, vsync: this);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: BaseAppBar(
        baseTitle: S.of(context).my_contract,
        actions: <Widget>[
          FlatButton(
            onPressed: () {},
            child: Text(
              "提取奖励",
              style: TextStyle(color: HexColor("#1F81FF")),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _myProfitWidget(),
            _tabBarWidget(),
            _childrenWidget(),
          ],
        ),
      ),
    );
  }

  _myProfitWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  //color: Colors.black12,
                  //blurRadius: 8.0,
                  color: HexColor("#000000").withOpacity(0.06),
                  blurRadius: 16.0,
                ),
              ],
            ),
            margin: const EdgeInsets.only(left: 15.0, right: 15, bottom: 20, top: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 28),
                  child: Text(
                    "3,043",
                    style: TextStyle(
                      color: HexColor("#228BA1"),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    "当前奖励",
                    style: TextStyle(
                      color: HexColor("#333333"),
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    color: HexColor("#F2F2F2"),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 10,
                      ),
                      child: RichText(
                        text: TextSpan(
                          text: "历史奖励",
                          style: TextStyle(
                            fontSize: 12,
                            color: HexColor("#333333"),
                          ),
                          children: [
                            TextSpan(
                              text: " " + "20,492",
                              style: TextStyle(
                                fontSize: 12,
                                color: HexColor("#333333"),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 28, bottom: 25),
                  child: ClickOvalButton(
                    "提取奖励",
                    () {
                      _showAlertView();
                    },
                    height: 32,
                    width: 160,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _tabBarWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            color: Colors.white,
            child: TabBar(
              isScrollable: true,
              //indicatorColor: Theme.of(context).primaryColor,
              indicatorPadding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              indicatorColor: HexColor("#228BA1"),
              indicatorWeight: 3,
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: HexColor("#333333"),
              indicatorSize: TabBarIndicatorSize.label,
              tabs: _contractTypeModels
                  .map((MyContractModel model) => Tab(
                        child: Text(
                          model.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  _childrenWidget() {
    return Expanded(
      child: RefreshConfiguration.copyAncestor(
        enableLoadingWhenFailed: true,
        context: context,
        headerBuilder: () => WaterDropMaterialHeader(
          backgroundColor: Theme.of(context).primaryColor,
        ),
        footerTriggerDistance: 30.0,
        child: TabBarView(
          controller: _tabController,
          //physics: NeverScrollableScrollPhysics(),
          children: _contractTypeModels.map((model) => Map3NodeListPage(model)).toList(),
        ),
      ),
    );
  }

  _showAlertView() {
    UiUtil.showAlertView(context,
        title: "提取奖励",
        actions: [
          ClickOvalButton(
            "确认提取",
            () {
              Navigator.pop(context);
              Application.router.navigateTo(context, Routes.map3node_collect_page);
            },
            width: 200,
            height: 38,
            fontSize: 16,
          ),
        ],
        content: "您一共创建或参与了3个Map3节点，截止昨日可提奖励为: 3,043 HYN 确定全部提取到钱包",
        boldContent: "(Star01)",
        boldStyle: TextStyle(
          color: HexColor("#999999"),
          fontSize: 12,
          height: 1.8,
        ),
        suffixContent: " 吗？");
  }
}
