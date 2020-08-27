import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/map3page/map3_node_normal_confirm_page.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class Map3NodeCreateConfirmPage extends StatefulWidget {
  Map3NodeCreateConfirmPage();

  @override
  _Map3NodeCreateConfirmState createState() => new _Map3NodeCreateConfirmState();
}

class _Map3NodeCreateConfirmState extends State<Map3NodeCreateConfirmPage> {
  var _localImagePath;
  List<String> _titleList = ["图标", "名称", "节点号", "首次抵押", "管理费", "网址", "安全联系", "描述", "云服务商", "节点地址"];
  List<String> _detailList = [
    "",
    "派大星",
    "PB2020",
    "200,000 HYN",
    "20%",
    "www.hyn.space",
    "12345678901",
    "欢迎参加我的合约，前10名参与者返10%管理。",
    "亚马逊云",
    "美国东部（弗吉尼亚北部）"
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: '确认创建节点',
      ),
      backgroundColor: Colors.white,
      body: _pageView(context),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _pageView(BuildContext context) {
    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;

    return Column(
      children: <Widget>[
        _headerWidget(),
        Expanded(
          child: CustomScrollView(
            slivers: <Widget>[
              _contentWidget(),
            ],
          ),
        ),
        _confirmButtonWidget(),
      ],
    );
  }

  Widget _headerWidget() {
    return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              "你即将要创建如下Map3节点",
              style: TextStyle(
                color: HexColor("#333333"),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ));
  }

  Widget _contentWidget() {
    return SliverToBoxAdapter(
      child: ListView.separated(
        itemBuilder: (context, index) {
          var title = _titleList[index];
          var detail = _detailList[index];

          return Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: detail.isNotEmpty ? 18 : 14, horizontal: 14),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 100,
                    child: Text(
                      title,
                      style: TextStyle(color: HexColor("#999999"), fontSize: 14),
                    ),
                  ),
                  detail.isNotEmpty
                      ? Expanded(
                    child: Text(
                      detail,
                      style: TextStyle(color: HexColor("#333333"), fontSize: 14),
                    ),
                  )
                      : Image.asset(
                    _localImagePath ?? "res/drawable/ic_map3_node_item_2.png",
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),

                  //Spacer(),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 0.5,
            color: HexColor("#F2F2F2"),
          );
        },
        itemCount: _detailList.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
      ),
    );
  }

  Widget _confirmButtonWidget() {
    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 18),
      child: ClickOvalButton(
        "提交",
        () async {
          Application.router
              .navigateTo(context, Routes.map3node_normal_confirm_page+ "?actionEvent=${Map3NodeActionEvent.CREATE.index}");
        },
        height: 46,
        width: MediaQuery.of(context).size.width - 37 * 2,
        fontSize: 18,
      ),
    );
  }
}
