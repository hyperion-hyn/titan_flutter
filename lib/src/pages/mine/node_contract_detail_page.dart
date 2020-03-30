import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/load_data_bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/mine/my_map3_contract_page.dart';
import 'package:titan/src/pages/node/map3page/map3_node_create_join_contract_page.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';

class NodeContractDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NodeContractDetailState();
  }
}

class _NodeContractDetailState extends State<NodeContractDetailPage> {
  LoadDataBloc loadDataBloc = LoadDataBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    loadDataBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("节点抵押合约详情")),
      body: Container(
        color: HexColor("#f5f5f5"),
        child: LoadDataContainer(
          bloc: loadDataBloc,
          onRefresh: () async {},
          child: CustomScrollView(
            slivers: <Widget>[
              _contractIntroductionRow(context, 3),
              _Divider(),
              _contractStatusRow(context, 3),
              _Divider(),
              _contractJoinerListRow(context, 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _Divider({height = 10.0, bool isSimple = false}) {
    return isSimple
        ? Container(
            height: height,
          )
        : SliverToBoxAdapter(
            child: Container(
            height: height,
          ));
  }

  Widget _contractIntroductionRow(BuildContext context, int index) {
    bool hasRemind = (index == 3) ? true : false;
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(left: 10.0, right: 10, top: 5, bottom: 10),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Image.asset(
                    "res/drawable/ic_map3_node_item.png",
                    width: 70,
                    height: 70,
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 4,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(child: Text("MAP3节点（V0.8）", style: TextStyles.textC333S14)),
                        ],
                      ),
                      Container(
                        height: 2,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text("启动共需1，000，000HYN", style: TextStyles.textC333S14),
                      )
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [1, 2, 3].map((value) {
                  String title = "";
                  String detail = "";
                  switch (value) {
                    case 1:
                      title = "期满年化奖励";
                      detail = "8.9%";
                      break;

                    case 2:
                      title = "合约期限";
                      detail = "1月";
                      break;

                    case 3:
                      title = "管理费";
                      detail = "20%";
                      break;
                  }
                  return Expanded(
                    child: Center(
                        child: Column(
                      children: <Widget>[
                        Text(title, style: TextStyles.textC9b9b9bS12),
                        Container(
                          height: 4,
                        ),
                        Text(detail, style: TextStyles.textC333S14)
                      ],
                    )),
                  );
                }).toList(),
              ),
            ),
            if (hasRemind)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
                child: Text("注：合约生效满3个月后，即可提取50%奖励", style: TextStyles.textCf29a6eS12),
              )
          ],
        ),
      ),
    );
  }

  Widget _contractStatusRow(BuildContext context, int index) {
    return SliverToBoxAdapter(
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        color: HexColor('#FDFBEA'),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Text("正在创建中，等待区块链网络验证", style: TextStyles.textC9b9b9bS12),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
                  child: Row(
                    children: [1, 2, 3].map((value) {
                      String title = "";
                      String detail = "";
                      TextStyle style = TextStyle(fontSize: 12, color: Colors.grey);
                      switch (value) {
                        case 1:
                          title = "你已投入(HYN)";
                          detail = "20,000";
                          style = TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold);
                          break;

                        case 2:
                          title = "预期产出(HYN)";
                          detail = "21,000";
                          style = TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold);
                          break;

                        case 3:
                          title = "获得管理费(HYN)";
                          detail = "100";
                          style = TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold);
                          break;
                      }
                      return Expanded(
                        child: Center(
                            child: Column(
                          children: <Widget>[
                            Text(detail, style: style),
                            Container(
                              height: 8,
                            ),
                            Text(title, style: TextStyles.textC9b9b9bS12),
                          ],
                        )),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [1, 2, 3, 4].map((value) {
                      String title = "";
                      String detail = "";
                      TextStyle style = TextStyle(fontSize: 12, color: Colors.grey);
                      Function onPressed = (){};
                      switch (value) {
                        case 1:
                          title = "取回资金";
                          detail = "20,000";
                          style = TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold);
                          break;

                        case 2:
                          title = "增加投入";
                          detail = "21,000";
                          style = TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold);
                          onPressed = () {
                            Application.router.navigateTo(context, Routes.map3node_create_join_contract_page + "?pageType=${Map3NodeCreateJoinContractPage.CONTRACT_PAGE_TYPE_JOIN}");
                          };
                          break;

                        case 3:
                          title = "我要投入";
                          detail = "100";
                          style = TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold);
                          onPressed = () {
                            Application.router.navigateTo(context, Routes.map3node_create_join_contract_page + "?pageType=${Map3NodeCreateJoinContractPage.CONTRACT_PAGE_TYPE_JOIN}");
                          };
                          break;

                        case 4:
                          title = "分享好友";
                          detail = "100";
                          style = TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold);
                          onPressed = () {
                            Share.text(S.of(context).share, "http://baidu.com", 'text/plain');
                          };
                          break;
                      }
                      return MaterialButton(
                        height: 30,
                        minWidth: 20,
                        color: Colors.white,
                        onPressed: onPressed,
                        child: Text(title, style: TextStyle(fontSize: 12, color: Colors.black)),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          _Divider(height: 4.0, isSimple: true),
          _contractProgressWidget(),
        ],
      ),
    );
  }

  Widget _contractJoinerListRow(BuildContext context, int index) {
    return SliverToBoxAdapter(
        child: Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12.0),
          color: Colors.white,
          child: Column(
            children: [1, 2].map((int value) {
              String title = "";
              String detail = "";
              double bottom = 0.0;
              switch (value) {
                case 1:
                  title = "创建时间:";
                  detail = "2020-10-10";
                  bottom = 4.0;
                  break;

                case 2:
                  title = "参与账户:";
                  detail = "21,000";
                  break;
              }
              return Padding(
                padding: EdgeInsets.only(bottom: bottom),
                child: Row(
                  children: <Widget>[
                    Text(title, style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
                    Spacer(),
                    Text(detail, style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.normal)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        _Divider(height: 4.0, isSimple: true),
        Container(
          color: Colors.white,
          child: Column(
            children: [0, 1, 2, 3, 4].map((value) {
              return value == 0
                  ? Container(
                      padding: const EdgeInsets.all(12.0),
                      color: Colors.white,
                      child: Row(
                        //
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                        children: [
                          Expanded(
                            child: Text("参与账户", style: TextStyles.textC9b9b9bS12),
                          ),
                          Expanded(child: Text("投入(HYN)", style: TextStyles.textC9b9b9bS12)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text("时间", style: TextStyles.textC9b9b9bS12),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(12.0),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(value == 1 ? "Moo（发起人）" : "Moo$value",
                                  style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500)),
                              Container(
                                height: 4.0,
                              ),
                              Text("0xdasf9fdafu31ffadf", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          Text("200,000",
                              style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500)),
                          Text("2020-10-10", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    );
            }).toList(),
          ),
        ),
      ],
    ));
  }

  Widget _contractProgressWidget() {

    double horizontal = 25;
    double sectionWidth = (MediaQuery.of(context).size.width - horizontal * 2.0) * 0.2;
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    width: 10,
                    height: 10,
                    //color: Colors.red,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getStatusColor(ContractStatus.SuspendRun),
                        border: Border.all(color: Colors.grey, width: 1.0)),
                  ),
                ),
                Text.rich(TextSpan(children: [
                  TextSpan(text: "等待启动，剩余", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  TextSpan(
                    text: "2天",
                    style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                ])),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text("7天", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
                Container(width: sectionWidth,),
                Text("90天", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
                Container(width: sectionWidth*0.5,),
                Text("90天", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal:horizontal),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.blue, width: 1.0)),
              ),
              Container(
                height: 2.5,
                width: sectionWidth,
                color: Colors.green,
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.grey, width: 1.0)),
              ),
                  Container(
                    height: 2.5,
                    width: sectionWidth,
                    color: Colors.green,
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 1.0)),
                  ),
                  Container(
                    height: 2.5,
                    width: sectionWidth,
                    color: Colors.green,
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 1.0)),
                  ),
                  Container(
                    height: 2.5,
                    width: sectionWidth,
                    color: Colors.green,
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 1.0)),
                  ),

            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("待启动", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
                Text("启动", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Text("中期可取50%奖励",
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal)),
                ),
                Text("到期", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
                Text("已提取", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  HexColor _getStatusColor(ContractStatus status) {
    var statusColor = HexColor('#EED097');

    switch (status) {
      case ContractStatus.SuspendRun:
        statusColor = HexColor('#EED097');
        break;

      case ContractStatus.Running:
        statusColor = HexColor('#3FF78C');
        break;

      case ContractStatus.Expired:
        statusColor = HexColor('#867B7B');
        break;

      case ContractStatus.Withdrawal:
        statusColor = HexColor('#867B7B');
        break;

      case ContractStatus.FailRun:
        statusColor = HexColor('#F22504');
        break;

      default:
        break;
    }
    return statusColor;
  }

}
