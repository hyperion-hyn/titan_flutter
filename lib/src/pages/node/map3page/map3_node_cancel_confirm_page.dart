import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';

class Map3NodeCancelConfirmPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Map3NodeCancelConfirmState();
  }
}

class _Map3NodeCancelConfirmState extends State<Map3NodeCancelConfirmPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("撤销抵押")),
      //backgroundColor: Color(0xffF3F0F5),
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 18, right: 18),
                        child: Row(
                          children: <Widget>[
                            Image.asset(
                              "res/drawable/map3_node_default_avatar.png",
                              width: 42,
                              height: 42,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text.rich(TextSpan(children: [
                                  TextSpan(text: "天道酬勤唐唐", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                  TextSpan(
                                      text: "  编号 PB2020", style: TextStyle(fontSize: 13, color: HexColor("#333333"))),
                                ])),
                                Container(
                                  height: 4,
                                ),
                                Text("节点地址 oxfdaf89fdaff", style: TextStyles.textC9b9b9bS12),
                              ],
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  color: HexColor("#1FB9C7").withOpacity(0.08),
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Text("第一期", style: TextStyle(fontSize: 12, color: HexColor("#5C4304"))),
                                ),
                                Container(
                                  height: 4,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 16, right: 16),
                        child: Container(
                          color: HexColor("#F2F2F2"),
                          height: 0.5,
                        ),
                      ),
                      nodeWidget(
                          context,
                          NodeItem(
                            1,
                            "Map3云节点",
                            "0.9",
                            1,
                            "1000000",
                            0.2,
                            0.1,
                            0.16,
                            180,
                            2,
                            100,
                            true,
                            "0",
                            "0",
                            "20, 30",
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                  child: Container(
                    color: HexColor("#F4F4F4"),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 18),
                        child: Row(
                          children: <Widget>[
                            Text("到账钱包", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 16, right: 8, bottom: 18),
                        child: Row(
                          children: <Widget>[
                            Image.asset(
                              "res/drawable/map3_node_default_avatar.png",
                              width: 42,
                              height: 42,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text.rich(TextSpan(children: [
                                  TextSpan(text: "大道至简", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                  TextSpan(text: "", style: TextStyles.textC333S14bold),
                                ])),
                                Container(
                                  height: 4,
                                ),
                                Text("${UiUtil.shortEthAddress("钱包地址 oxfdaf89fda47sn43sff", limitLength: 9)}",
                                    style: TextStyles.textC9b9b9bS12),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                  child: Container(
                    color: HexColor("#F4F4F4"),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 12, bottom: 12, right: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "*",
                          style: TextStyle(fontSize: 22, color: HexColor("#FF4C3B")),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: Text(
                            "撤销抵押将会影响节点进度，剩余抵押不足20%节点将会被取消",
                            style: TextStyle(fontSize: 14, color: HexColor("#333333"), height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ])),
            ),
            _confirmButtonWidget(),
          ],
        ),
      ),
    );
  }

  Widget _confirmButtonWidget() {
    return Container(
      /*decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 4.0,
          ),
        ],
      ),*/
      constraints: BoxConstraints.expand(height: 50),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: FlatButton(
                color: HexColor("#F2F2F2"),
                child: Text("确认撤销", style: TextStyle(fontSize: 16, color: HexColor("#999999"))),
                onPressed: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (BuildContext context) {
                        return EnterWalletPasswordWidget();
                      }).then((walletPassword) async {
                    if (walletPassword == null) {
                      return;
                    }
                  });
                }),
          ),
          Expanded(
            flex: 1,
            child: FlatButton(
                color: Theme.of(context).primaryColor,
                child: Text("再想想", style: TextStyle(fontSize: 16, color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ),
        ],
      ),
    );
  }
}

Widget nodeWidget(BuildContext context, NodeItem nodeItem) {
  return Container(
    color: Colors.white,
    child: Column(
      children: <Widget>[
        nodeIntroductionWidget(context, nodeItem),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
            height: 2,
          ),
        ),
        nodeServerWidget(context, nodeItem),
      ],
    ),
  );
}

Widget nodeIntroductionWidget(BuildContext context, NodeItem nodeItem) {
  //var nodeItem = widget.contractNodeItem.contract;

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
                  Expanded(child: Text(nodeItem.name, style: TextStyle(fontWeight: FontWeight.bold)))
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
        Column(
          children: <Widget>[
            Text("${FormatUtil.formatPercent(nodeItem.annualizedYield)}", style: TextStyles.textCff4c3bS20),
            Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: Text(S.of(context).annualized_rewards, style: TextStyles.textC99000000S13),
            )
          ],
        )
      ],
    ),
  );
}

Widget nodeServerWidget(BuildContext context, NodeItem nodeItem, {String provider = "", String region = ""}) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [1, 2, 3].map((value) {
        var title = "";
        var detail = "";
        switch (value) {
          case 1:
            title = "创建日期";
            detail = "2020.02.18";
            break;

          case 2:
            title = "参与地址";
            detail = "12个";
            break;

          case 3:
            title = "抵押金额";
            detail = "900,0000";
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
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 14, color: HexColor("#92979A")),
                  )),
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
