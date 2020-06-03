import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:sprintf/sprintf.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/data/cache/memory_cache.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/map3page/map3_node_pronounce_page.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/model/node_page_entity_vo.dart';
import 'package:titan/src/pages/node/widget/node_active_contract_widget.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/route_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/click_oval_button.dart';

class Map3NodePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Map3NodeState();
  }
}

class _Map3NodeState extends State<Map3NodePage> {
  LoadDataBloc loadDataBloc = LoadDataBloc();
  NodeApi _nodeApi = NodeApi();
  NodePageEntityVo _nodePageEntityVo = MemoryCache.nodePageData;
  int currentPage = 0;
  List<ContractNodeItem> activeContractList = [];


  @override
  void initState() {
    super.initState();

    if (!MemoryCache.hasNodePageData) {
      loadDataBloc.add(LoadingEvent());
    } else {
      getNetworkData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xfff5f5f5),
      //color: Color(0xffFDFAFF),
      child: LoadDataContainer(
        enablePullUp: (_nodePageEntityVo.contractNodeList != null && _nodePageEntityVo.contractNodeList.length > 0),
        bloc: loadDataBloc,
        onLoadData: () async {
          getNetworkData();
        },
        onRefresh: () {
          getNetworkData();
        },
        onLoadingMore: () {
          getMoreNetworkData();
        },
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(child: _map3HeadItem()),
            if (activeContractList.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: NodeActiveContractWidget(loadDataBloc),
                ),
              ),
            SliverToBoxAdapter(
              child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(left: 15.0, right: 15, top: 17, bottom: 11),
                  child: Text(S.of(context).wait_start_node_contract,
                      style: TextStyle(fontWeight: FontWeight.w500, color: HexColor("#000000")))),
            ),
            if (_nodePageEntityVo.contractNodeList.isNotEmpty) _pendingListWidget(),
            _emptyListWidget(),
          ],
        ),
      ),
    );
  }

  void getNetworkData() async {
    try {
      currentPage = 0;
      _nodePageEntityVo = MemoryCache.nodePageData;

      NodePageEntityVo netData = await _nodeApi.getNodePageEntityVo();
      activeContractList = await _nodeApi.getContractActiveList();

      NodePageEntityVo cloneData = netData.clone();
      cloneData.nodeHeadEntity?.lastRecordMessage = null;
      if (!cloneData.isEqual(MemoryCache.nodePageData)) {
        MemoryCache.nodePageData = cloneData;
        _nodePageEntityVo = MemoryCache.nodePageData;
      }

      if (mounted) {
        setState(() {
          loadDataBloc.add(RefreshSuccessEvent());
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loadDataBloc.add(LoadFailEvent());
        });
      }
    }
  }

  void getMoreNetworkData() async {
    try {
      currentPage = currentPage + 1;
      List<ContractNodeItem> contractNodeList = await _nodeApi.getContractPendingList(currentPage);
      if (contractNodeList.length > 0) {
        _nodePageEntityVo.contractNodeList.addAll(contractNodeList);
        loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        loadDataBloc.add(LoadMoreEmptyEvent());
      }
      setState(() {});
    } catch (e) {
      loadDataBloc.add(LoadMoreFailEvent());
    }
  }

  Widget _pendingListWidget() {
    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
//      if (index == 0) {
//        return Column(
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: <Widget>[getMap3NodeWaitItem(context, _nodePageEntityVo.contractNodeList[index])],
//        );
//      } else {
      return Container(
          padding: EdgeInsets.only(top: index == 0 ? 8 : 0),
          color: Colors.white,
          child: getMap3NodeWaitItem(context, _nodePageEntityVo.contractNodeList[index]));
//      }
    }, childCount: _nodePageEntityVo.contractNodeList.length));
  }

  Widget _emptyListWidget() {
    // empty
    if (_nodePageEntityVo.contractNodeList.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.only(top: 48.0),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Image.asset(
                'res/drawable/ic_empty_contract.png',
                width: 120,
                height: 120,
              ),
              SizedBox(height: 8),
              SizedBox(
                child: Text(
                  S.of(context).no_pengding_node_contract_hint,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
                width: 160,
              ),
              SizedBox(height: 64),
            ],
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Container(),
    );
  }

  Widget _map3HeadItem() {
    if (_nodePageEntityVo.nodeHeadEntity == null || _nodePageEntityVo == null) {
      return Container();
    }
    return Container(
      color: Color(0xfff5f5f5),
      child: Stack(
        children: <Widget>[
          Container(
              color: Theme.of(context).primaryColor,
              height: 162,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: SizedBox(),
                  ),
                  Image.asset(
                    "res/drawable/ic_map3_node_head.png",
                    width: 230,
                    height: 135,
                  ),
                ],
              )),
          Container(
            height: 162,
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  sprintf(S.of(context).earth_outpace_server_node, [_nodePageEntityVo.nodeHeadEntity.instanceCount]),
                  style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  S.of(context).map_provide_stable_server,
                  style: TextStyle(fontSize: 12, color: HexColor("#e6ffffff")),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8.0,
                ),
              ],
            ),
            margin: const EdgeInsets.only(left: 15, right: 15, top: 127, bottom: 16),
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 19, top: 13, bottom: 17),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      ClipRRect(
                        child: Image.asset("res/drawable/ic_map3_node_item_2.png",
                            width: 80, height: 80, fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      SizedBox(width: 16),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                    child: Text("${_nodePageEntityVo.nodeHeadEntity.node.name}（V${_nodePageEntityVo.nodeHeadEntity.node.version}）",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: DefaultColors.colorcc000000))),
                                InkWell(
                                  onTap: () {
                                    String webUrl =
                                        FluroConvertUtils.fluroCnParamsEncode(
                                            "http://baidu.com");
                                    String webTitle =
                                        FluroConvertUtils.fluroCnParamsEncode(
                                            "如何新开Map3节点");
                                    Application.router.navigateTo(
                                        context,
                                        Routes.toolspage_webview_page +
                                            '?initUrl=$webUrl&title=$webTitle');
                                  },
                                  child: Text("开通教程",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: DefaultColors.color66000000,
                                          /*decoration:
                                              TextDecoration.underline*/)),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                              child: Text("    ${_nodePageEntityVo.nodeHeadEntity.node.content}",
                                  style: TextStyle(fontSize: 11, height: 1.8, color: DefaultColors.color99000000)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ClickOvalButton(S.of(context).create_contract,(){
                      _pushContractListAction();
                    }),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future _pushContractListAction() async {
    var currentRouteName = RouteUtil.encodeRouteNameWithoutParams(context)??"";
    await Application.router.navigateTo(context, Routes.map3node_product_list + '?entryRouteName=$currentRouteName');
    final result = ModalRoute.of(context).settings?.arguments;
    print("[detail] -----> back, _broadcaseContractAction, result:$result");
    // 记得清理
    if (result != null && result is Map) {
      var item = result["result"];
      if (item is ContractNodeItem) {
        _pushContractDetail(item);
      }

      result["result"] = null;
    }
  }

  Future _pushContractDetail(ContractNodeItem contractNodeItem) async {
    Application.router.navigateTo(context, Routes.map3node_contract_detail_page + "?contractId=${contractNodeItem.id}");
  }

  @override
  void dispose() {
    loadDataBloc.close();
    super.dispose();
  }
}

Widget getMap3NodeWaitItem(BuildContext context, ContractNodeItem contractNodeItem) {
  if (contractNodeItem == null) return Container();

  var state = contractNodeItem.stateValue;

  var isNotFull = int.parse(contractNodeItem.remainDelegation) > 0;
  var fullDesc = "";
  var dateDesc = "";
  var isPending = false;
  switch (state) {
    case ContractState.PRE_CREATE:
    case ContractState.PENDING:
      dateDesc = S.of(context).left + FormatUtil.timeStringSimple(context, contractNodeItem.launcherSecondsLeft);
      dateDesc = S.of(context).active + dateDesc;
      fullDesc = !isNotFull ? S.of(context).delegation_amount_full : "";
      isPending = true;
      break;

    case ContractState.ACTIVE:
      dateDesc = S.of(context).left + FormatUtil.timeStringSimple(context, contractNodeItem.completeSecondsLeft);
      dateDesc = S.of(context).expired + dateDesc;
      break;

    case ContractState.DUE:
      dateDesc = S.of(context).contract_had_expired;
      break;

    case ContractState.CANCELLED:
    case ContractState.CANCELLED_COMPLETED:
    case ContractState.FAIL:
      dateDesc = S.of(context).launch_fail;
      break;

    case ContractState.DUE_COMPLETED:
      dateDesc = S.of(context).contract_had_stop;
      break;

    default:
      break;
  }

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8.0,
        ),
      ],
    ),
    margin: const EdgeInsets.only(left: 15.0, right: 15, bottom: 9),
    child: Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16, top: 7, bottom: 7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
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
                    TextSpan(
                        text: "天道酬勤唐唐", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    TextSpan(text: "", style: TextStyles.textC333S14bold),
                  ])),
                  Container(
                    height: 4,
                  ),
                  Text("节点地址 ${UiUtil.shortEthAddress(contractNodeItem.owner, limitLength: 6)}", style: TextStyles.textC9b9b9bS12),
                ],
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(S.of(context).number + "${contractNodeItem.contractCode ?? ""}",
                      style: TextStyle(fontSize: 13, color: HexColor("#333333"))),
                  Container(
                    height: 4,
                  ),
                  Container(
                    color: HexColor("#1FB9C7").withOpacity(0.08),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text("第一期", style: TextStyle(fontSize: 12, color: HexColor("#5C4304"))),
                  ),
                ],
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 12, left: 48),
            child: Row(
              children: [0, 0.5, 1, 0.5, 2].map((value) {
                if (value == 0.5) {
                  return SizedBox(width: 32);
                }

                String title = "";
                String detail = "";
                switch (value) {
                  case 0:
                    detail = S.of(context).n_day('${contractNodeItem.contract.duration}');
                    title = "节点期限";
                    break;

                  case 1:
                    detail = "10%";
                    title = "管理费";
                    break;

                  case 2:
                    detail = "${FormatUtil.formatPercent(contractNodeItem.contract.annualizedYield)}";
                    title = S.of(context).annualized_rewards;
                    break;

                  default:
                    break;
                }

                return Column(
                  children: <Widget>[
                    Text(
                      detail,
                      style: TextStyle(fontSize: 16, color: value == 2 ? HexColor("#FF4C3B") : HexColor("#333333")),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      title,
                      style: TextStyle(fontSize: 12, color: HexColor("#999999")),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "节点公告：",
                style: TextStyle(fontSize: 10, color: HexColor("#999999")),
              ),
              Flexible(
                child: Text(
                  "大家快来参与我的节点吧，收益高高，收益真的很高，大家相信我，不会错的，快投吧，一会儿没机会了……",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: HexColor("#333333")),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 12),
            child: Divider(height: 1, color: Color(0x2277869e)),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    isNotFull
                        ? RichText(
                            text: TextSpan(
                                text: S.of(context).remain,
                                style: TextStyles.textC9b9b9bS12,
                                children: <TextSpan>[
                                  TextSpan(
                                      text: "${FormatUtil.formatNum(int.parse(contractNodeItem.remainDelegation))}",
                                      style: TextStyles.textC7c5b00S12),
                                  TextSpan(text: "HYN", style: TextStyles.textC9b9b9bS12),
                                ]),
                          )
                        : RichText(
                            text: TextSpan(text: fullDesc, style: TextStyles.textC9b9b9bS12, children: <TextSpan>[]),
                          ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(dateDesc, style: TextStyle(color: Map3NodeUtil.stateColor(state), fontSize: 12)),
                  ],
                ),
                Spacer(),
                SizedBox(
                  height: 30,
//                width: 80,
                  child: FlatButton(
                    color: HexColor("#FF15B2D2"),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    onPressed: () {

                      Application.router.navigateTo(
                          context, Routes.map3node_contract_detail_page + "?contractId=${contractNodeItem.id}");
                    },
                    child: Text(isPending ? S.of(context).check_join : S.of(context).detail,
                        style: TextStyle(fontSize: 13, color: Colors.white)),
                    //style: TextStyles.textC906b00S13),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}

Widget getMap3NodeInfoItem(BuildContext context, ContractNodeItem contractNodeItem) {
  if (contractNodeItem == null) return Container();

  var state = contractNodeItem.stateValue;

  var isNotFull = int.parse(contractNodeItem.remainDelegation) > 0;
  var fullDesc = "";
  var dateDesc = "";
  var isPending = false;
  switch (state) {
    case ContractState.PRE_CREATE:
    case ContractState.PENDING:
      dateDesc = S.of(context).left + FormatUtil.timeStringSimple(context, contractNodeItem.launcherSecondsLeft);
      dateDesc = S.of(context).active + dateDesc;
      fullDesc = !isNotFull ? S.of(context).delegation_amount_full : "";
      isPending = true;
      break;

    case ContractState.ACTIVE:
      dateDesc = S.of(context).left + FormatUtil.timeStringSimple(context, contractNodeItem.completeSecondsLeft);
      dateDesc = S.of(context).expired + dateDesc;
      break;

    case ContractState.DUE:
      dateDesc = S.of(context).contract_had_expired;
      break;

    case ContractState.CANCELLED:
    case ContractState.CANCELLED_COMPLETED:
    case ContractState.FAIL:
      dateDesc = S.of(context).launch_fail;
      break;

    case ContractState.DUE_COMPLETED:
      dateDesc = S.of(context).contract_had_stop;
      break;

    default:
      break;
  }


  String _pronounceText = "";
  _pronounceText = "大家快来参与我的节点吧，收益高高，收益真的很高，大家相信我，不会错的，快投吧，一会儿没机会了……";


  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
    ),
    child: Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16, bottom: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Image.asset(
                "res/drawable/map3_node_default_avatar.png",
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
              SizedBox(
                width: 6,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: "天道酬勤唐唐", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    TextSpan(text: " "+ S.of(context).number + "${contractNodeItem.contractCode ?? ""}", style: TextStyle(fontSize: 13, color: HexColor("#333333"))),
                  ])),
                  Container(
                    height: 4,
                  ),
                  Text("节点地址 ${UiUtil.shortEthAddress(contractNodeItem.owner, limitLength: 6)}", style: TextStyles.textC9b9b9bS12),
                ],
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(dateDesc, style: TextStyle(color: Map3NodeUtil.stateColor(state), fontSize: 12)),
                  Container(
                    height: 4,
                  ),
                  Container(
                    color: HexColor("#1FB9C7").withOpacity(0.08),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text("第一期", style: TextStyle(fontSize: 12, color: HexColor("#5C4304"))),
                  ),
                ],
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 12, right: 36),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "节点公告：",
                      style: TextStyle(fontSize: 12, color: HexColor("#999999")),
                    ),
                    Flexible(
                      child: Text(
                        _pronounceText,
                        maxLines: 3,
                        textAlign: TextAlign.justify,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: HexColor("#333333")),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: InkWell(
                    //color: HexColor("#FF15B2D2"),
                    //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    onTap: () async{
                      String text = await Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              Map3NodePronouncePage()));
                      if (text.isNotEmpty) {
                        _pronounceText = text;
                        print("[Pronounce] _pronounceText:${_pronounceText}");
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Image.asset(
                          "res/drawable/map3_node_edit.png",
                          width: 12,
                          height: 12,
                        ),
                        SizedBox(width: 4,),
                        Text("编辑",
                            style: TextStyle(fontSize: 14, color: HexColor("#1F81FF"))),
                      ],
                    ),
                    //style: TextStyles.textC906b00S13),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 12),
            child: Divider(height: 1, color: Color(0x2277869e)),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[

                    Text("期满自动续约", style: TextStyle(color: HexColor("#333333"), fontSize: 14)),
                  ],
                ),
                Spacer(),
                SizedBox(
                  height: 30,
//                width: 80,
                  child: InkWell(
                    //color: HexColor("#FF15B2D2"),
                    //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    onTap: () {
                      Application.router.navigateTo(
                          context, Routes.map3node_contract_detail_page + "?contractId=${contractNodeItem.id}");
                    },
                    child: Row(
                      children: <Widget>[
                        Text("已开启",
                            style: TextStyle(fontSize: 14, color: HexColor("#008EAA"))),
                        Image.asset(
                          "res/drawable/map3_node_arrow.png",
                          width: 12,
                          height: 12,
                        ),
                      ],
                    ),
                    //style: TextStyles.textC906b00S13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget getMap3NodeWaitItem_old(BuildContext context, ContractNodeItem contractNodeItem) {
  if (contractNodeItem == null) return Container();

  var state = contractNodeItem.stateValue;

  var isNotFull = int.parse(contractNodeItem.remainDelegation) > 0;
  var fullDesc = "";
  var dateDesc = "";
  var isPending = false;
  switch (state) {
    case ContractState.PRE_CREATE:
    case ContractState.PENDING:
      dateDesc = S.of(context).left + FormatUtil.timeStringSimple(context, contractNodeItem.launcherSecondsLeft);
      dateDesc = S.of(context).active + dateDesc;
      fullDesc = !isNotFull ? S.of(context).delegation_amount_full : "";
      isPending = true;
      break;

    case ContractState.ACTIVE:
      dateDesc = S.of(context).left + FormatUtil.timeStringSimple(context, contractNodeItem.completeSecondsLeft);
      dateDesc = S.of(context).expired + dateDesc;
      break;

    case ContractState.DUE:
      dateDesc = S.of(context).contract_had_expired;
      break;

    case ContractState.CANCELLED:
    case ContractState.CANCELLED_COMPLETED:
    case ContractState.FAIL:
      dateDesc = S.of(context).launch_fail;
      break;

    case ContractState.DUE_COMPLETED:
      dateDesc = S.of(context).contract_had_stop;
      break;

    default:
      break;
  }

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8.0,
        ),
      ],
    ),
    margin: const EdgeInsets.only(left: 15.0, right: 15, bottom: 9),
    child: Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20, top: 7, bottom: 7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text.rich(TextSpan(children: [
                    TextSpan(text: S.of(context).number, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    TextSpan(text: "${contractNodeItem.contractCode ?? ""}", style: TextStyles.textC333S14bold),
                  ])),
                  Container(
                    width: 4,
                  ),
                  Text("${UiUtil.shortEthAddress(contractNodeItem.owner)}", style: TextStyles.textC9b9b9bS12),
                ],
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(S.of(context).launcher_func(UiUtil.shortEthAddress(contractNodeItem.ownerName)),
                      style: TextStyles.textC9b9b9bS12),
                  Container(
                    width: 4,
                  ),
                  Text(dateDesc, style: TextStyle(color: Map3NodeUtil.stateColor(state), fontSize: 12)),
                ],
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Divider(height: 1, color: Color(0x2277869e)),
          ),
          Column(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      Application.router.navigateTo(
                          context, Routes.map3node_contract_detail_page + "?contractId=${contractNodeItem.id}");
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Image.asset(
                          "res/drawable/ic_map3_node_item_contract.png",
                          width: 42,
                          height: 42,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                      child: Text("${contractNodeItem.contract.nodeName}",
                                          style: TextStyles.textCcc000000S14))
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 3.0),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                        S.of(context).highest +
                                            " ${FormatUtil.formatTenThousandNoUnit(contractNodeItem.contract.minTotalDelegation)}" +
                                            S.of(context).ten_thousand,
                                        style: TextStyles.textC99000000S10,
                                        maxLines: 1,
                                        softWrap: true),
                                    Text("  |  ", style: TextStyles.textC9b9b9bS12),
                                    Text(S.of(context).n_day('${contractNodeItem.contract.duration}'),
                                        style: TextStyles.textC99000000S10)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Text("${FormatUtil.formatPercent(contractNodeItem.contract.annualizedYield)}",
                                style: TextStyles.textCff4c3bS18),
                            Text(S.of(context).annualized_rewards, style: TextStyles.textC99000000S10)
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 9, bottom: 9),
            child: Divider(height: 1, color: Color(0x2277869e)),
          ),
          Row(
            children: <Widget>[
              isNotFull
                  ? Expanded(
                      child: RichText(
                        text:
                            TextSpan(text: S.of(context).remain, style: TextStyles.textC9b9b9bS12, children: <TextSpan>[
                          TextSpan(
                              text: "${FormatUtil.formatNum(int.parse(contractNodeItem.remainDelegation))}",
                              style: TextStyles.textC7c5b00S12),
                          TextSpan(text: "HYN", style: TextStyles.textC9b9b9bS12),
                        ]),
                      ),
                    )
                  : Expanded(
                      child: RichText(
                        text: TextSpan(text: fullDesc, style: TextStyles.textC9b9b9bS12, children: <TextSpan>[]),
                      ),
                    ),
              SizedBox(
                height: 30,
//                width: 80,
                child: FlatButton(
                  color: HexColor("#FF15B2D2"),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  onPressed: () {
                    Application.router.navigateTo(
                        context, Routes.map3node_contract_detail_page + "?contractId=${contractNodeItem.id}");
                  },
                  child: Text(isPending ? S.of(context).check_join : S.of(context).detail,
                      style: TextStyle(fontSize: 13, color: Colors.white)),
                  //style: TextStyles.textC906b00S13),
                ),
              ),
            ],
          )
        ],
      ),
    ),
  );
}


Widget nodeWidget(BuildContext context, NodeItem nodeItem) {
  return Container(
    color: Colors.white,
    child: Column(
      children: <Widget>[
        nodeIntroductionWidget(context, nodeItem),
        nodeBrowerWidget(),
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

Widget nodeBrowerWidget() {

  return Padding(
    padding: const EdgeInsets.only(bottom: 16, top: 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: InkWell(
            onTap: (){
              print("[Pronounce] text:1111111");

            },
            child: Text(
              "节点细则",
              style: TextStyle(fontSize:14, color: HexColor("#1F81FF")),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: InkWell(
            onTap: (){
              print("[Pronounce] text:2222");

            },
            child: Text(
              "访问节点",
              style: TextStyle(fontSize:14, color: HexColor("#1F81FF")),
            ),
          ),
        ),
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

Widget nodeServerWidget(BuildContext context, NodeItem nodeItem, {String provider="", String region=""}) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [1, 2, 3, 4, 5, 6].map((value) {

        var title = "";
        var detail = "";
        switch (value) {
          case 1:
            title = S.of(context).service_provider;
            detail = provider;
            break;

          case 2:
            title = S.of(context).node_location;
            detail = region;
            break;

          case 3:
            title = "管理费";
            detail = "20%";
            break;

          case 4:
            title = "自动续约";
            detail = "是";
            break;

          case 5:
            title = "节点公告";
            detail = "欢迎参加我的合约，前10名参与者返10%管理。";
            break;

          default:
            return SizedBox(
              height: 8,
            );
            break;
        }

        return Padding(
          padding: EdgeInsets.only(top: value == 1 ? 0:12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  width: 80,
                  child:
                  Text(title, style: TextStyle(fontSize: 14, color: HexColor("#92979A")),)),
              Expanded(child: Text(detail, style: TextStyle(fontSize: 15, color: HexColor("#333333")), maxLines: 2, overflow: TextOverflow.ellipsis,))
            ],
          ),
        );
      }).toList(),
    ),
  );
}
