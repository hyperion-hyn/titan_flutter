import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/node/map3page/map3_node_normal_confirm_page.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class Map3NodeExitPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Map3NodeExitState();
  }
}

class _Map3NodeExitState extends State<Map3NodeExitPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        centerTitle: true,
        title: Text(
          '终止节点',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),

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
                              width: 8,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text.rich(TextSpan(children: [
                                  TextSpan(text: "天道酬勤唐唐", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                  TextSpan(
                                      text: "  币龄: 12天", style: TextStyle(fontSize: 12, color: HexColor("#999999"))),
                                ])),
                                Container(
                                  height: 4,
                                ),
                                Text("节点地址 oxfdaf89fda47sn43sf9sllsaFf", style: TextStyles.textC9b9b9bS12),
                              ],
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  color: HexColor("#1FB9C7").withOpacity(0.08),
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Text("第二期", style: TextStyle(fontSize: 12, color: HexColor("#5C4304"))),
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
                      _nodeServerWidget(),
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
                                Text("${UiUtil.shortEthAddress("钱包地址 oxfdaf89fda47sn43sff", limitLength: 18)}",
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
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            "*",
                            style: TextStyle(fontSize: 22, color: HexColor("#FF4C3B")),
                          ),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: Text(
                            "终止后无法再次激活，请谨慎操作！",
//                            "撤销抵押将会影响节点进度，剩余抵押不足20%节点将会被取消",
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
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18.0, top: 10),
        child: Center(
          child: ClickOvalButton(
            "确认终止",
            () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => Map3NodeNormalConfirmPage(
                        actionEvent: Map3NodeActionEvent.CANCEL,
                      )));
            },
            height: 46,
            width: MediaQuery.of(context).size.width - 37 * 2,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _nodeServerWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [1, 0, 2, 0, 3, 0, 4].map((value) {
          var title = "";
          var detail = "";
          var subDetail = "";
          switch (value) {
            case 1:
              title = "创建日期";
              detail = "2020.02.18";
              subDetail = " (10天) ";
              break;

            case 2:
              title = "参与地址";
              detail = "12个";
              break;

            case 3:
              title = "节点总抵押";
              detail = "900,0000";
              break;

            case 4:
              title = "我的抵押";
              detail = "500,0000";
              break;

            default:
              return SizedBox(
                height: 12,
              );
              break;
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: title,
                    style: TextStyle(fontSize: 14, color: HexColor("#92979A")),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: RichText(
                  text: TextSpan(
                    text: detail,
                    style: TextStyle(fontSize: 14, color: HexColor("#333333")),
                    children: [
                      TextSpan(
                        text: subDetail,
                        style: TextStyle(fontSize: 12, color: HexColor("#999999")),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
