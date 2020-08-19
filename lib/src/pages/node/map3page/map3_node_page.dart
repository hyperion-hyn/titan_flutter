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
import 'package:titan/src/pages/node/map3page/map3_node_create_wallet_page.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/node/model/node_page_entity_vo.dart';
import 'package:titan/src/pages/node/widget/node_active_contract_widget.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/route_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/click_oval_button.dart';
import 'package:titan/src/widget/map3_nodes_widget.dart';

class Map3NodePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Map3NodeState();
  }
}

class _Map3NodeState extends State<Map3NodePage>
    with AutomaticKeepAliveClientMixin {
  LoadDataBloc loadDataBloc = LoadDataBloc();
  NodeApi _nodeApi = NodeApi();
  NodePageEntityVo _nodePageEntityVo = MemoryCache.nodePageData;
  int currentPage = 0;
  List<ContractNodeItem> activeContractList = [];
  List<ContractNodeItem> contractList = [];

  @override
  void initState() {
    super.initState();

    if (!MemoryCache.hasNodePageData) {
      loadDataBloc.add(LoadingEvent());
    } else {
      getNetworkData();
    }

    // todo: test_jison_0813
    for (int i = 0; i < 3; i++) {
      ContractNodeItem item = ContractNodeItem.onlyNodeId(i);
      contractList.add(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xfff5f5f5),
      //color: Color(0xffFDFAFF),
      child: LoadDataContainer(
        enablePullUp: (_nodePageEntityVo.contractNodeList != null &&
            _nodePageEntityVo.contractNodeList.length > 0),
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
            SliverToBoxAdapter(
              child: NodeActiveContractWidget(
                loadDataBloc,
                title: "我的节点",
              ),
            ),
            SliverToBoxAdapter(
              child: NodeActiveContractWidget(loadDataBloc),
            ),
            SliverToBoxAdapter(
              child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15, top: 17, bottom: 11),
                  child: Text(S.of(context).wait_start_node_contract,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: HexColor("#000000")))),
            ),
            _pendingListWidget(),
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
      List<ContractNodeItem> contractNodeList =
          await _nodeApi.getContractPendingList(currentPage);
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
      return Container(
          padding: EdgeInsets.only(top: index == 0 ? 8 : 0),
          color: Colors.white,
          child: getMap3NodeWaitItem(context, contractList[index]));
    }, childCount: contractList.length));
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

  _nodesMap() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        clipBehavior: Clip.antiAlias,
        shadowColor: Colors.black12,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.05, color: Colors.black12),
          borderRadius: BorderRadius.all(
            Radius.circular(16.0),
          ),
        ),
        child: Container(
          width: double.infinity,
          height: 162,
          child: Stack(
            children: <Widget>[
              Map3NodesWidget(),
              Positioned(
                left: 16,
                bottom: 32,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      sprintf(S.of(context).earth_outpace_server_node,
                          [_nodePageEntityVo.nodeHeadEntity.instanceCount]),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      S.of(context).map_provide_stable_server,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _map3HeadItem() {
    if (_nodePageEntityVo.nodeHeadEntity == null || _nodePageEntityVo == null) {
      return Container();
    }
    return Container(
      //color: Color(0xfff4f4f4),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          _nodesMap(),
          Container(
            color: Colors.white24,
            margin:
                const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 16),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text("${_nodePageEntityVo.nodeHeadEntity.node.name}",
//                          "${_nodePageEntityVo.nodeHeadEntity.node.name}（V${_nodePageEntityVo.nodeHeadEntity.node.version}）",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: DefaultColors.colorcc000000)),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          // todo: test_jison_0604
                          String webUrl = FluroConvertUtils.fluroCnParamsEncode(
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
                                              TextDecoration.underline*/
                            )),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: ClipRRect(
                          child: Image.asset(
                              "res/drawable/ic_map3_node_item_2.png",
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      SizedBox(width: 16),
                      Flexible(
                        child: Text(
                            "Map3已开放云节点抵押，通过创建和委托抵押合约有效提升服务质量和网络安全，提供全球去中心化地图服务。节点参与者将在合约到期后按抵押量获得奖励。",
                            style: TextStyle(
                                fontSize: 12,
                                height: 1.7,
                                color: DefaultColors.color99000000)),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ClickOvalButton(S.of(context).create_contract, () {
                    _pushContractListAction();
                  }),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future _pushContractListAction() async {
    var walletList = await WalletUtil.scanWallets();
    if (walletList.length == 0) {
      Application.router.navigateTo(
          context,
          Routes.map3node_create_wallet +
              "?pageType=${Map3NodeCreateWalletPage.CREATE_WALLET_PAGE_TYPE_CREATE}");
    } else {
      await Application.router.navigateTo(context,
          Routes.map3node_pre_create_contract_page + "?contractId=${1}");
    }

    //await Application.router.navigateTo(context, Routes.map3node_product_list + '?entryRouteName=$currentRouteName');
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
    Application.router.navigateTo(
        context,
        Routes.map3node_contract_detail_page +
            "?contractId=${contractNodeItem.id}");
  }

  @override
  void dispose() {
    loadDataBloc.close();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

Widget getMap3NodeWaitItem(
    BuildContext context, ContractNodeItem contractNodeItem) {
  if (contractNodeItem == null) return Container();

  var state = contractNodeItem.stateValue;

//  var isNotFull = int.parse(contractNodeItem.remainDelegation) > 0;
  var isNotFull = true;
  var fullDesc = "";
  var dateDesc = "";
  var isPending = false;
  switch (state) {
    case ContractState.PRE_CREATE:
    case ContractState.PENDING:
      dateDesc = S.of(context).left +
          FormatUtil.timeStringSimple(
              context, contractNodeItem.launcherSecondsLeft);
      dateDesc = S.of(context).active + dateDesc;
      fullDesc = !isNotFull ? S.of(context).delegation_amount_full : "";
      isPending = true;
      break;

    case ContractState.ACTIVE:
      dateDesc = S.of(context).left +
          FormatUtil.timeStringSimple(
              context, contractNodeItem.completeSecondsLeft);
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

  return InkWell(
    onTap: () async {
      var walletList = await WalletUtil.scanWallets();
      if (walletList.length == 0) {
        Application.router.navigateTo(
            context,
            Routes.map3node_create_wallet +
                "?pageType=${Map3NodeCreateWalletPage.CREATE_WALLET_PAGE_TYPE_CREATE}");
      } else {
        var entryRouteName =
            Uri.encodeComponent(Routes.map3node_contract_detail_page);
        Application.router.navigateTo(
            context,
            Routes.map3node_join_contract_page +
                "?entryRouteName=$entryRouteName&contractId=${1}");
      }
    },
    child: Container(
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
        padding: const EdgeInsets.all(16),
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
                          text: "天道酬勤唐唐",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      TextSpan(text: "", style: TextStyles.textC333S14bold),
                    ])),
                    Container(
                      height: 4,
                    ),
                    Text(
                        "节点地址 oxfdaf89fdaff ${UiUtil.shortEthAddress(contractNodeItem.owner, limitLength: 6)}",
                        style: TextStyles.textC9b9b9bS12),
                  ],
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                          text: "节点号",
                          style: TextStyle(
                            color: HexColor("#999999"),
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                                text:
                                    " ${contractNodeItem.contractCode ?? "PB2020"}",
                                style: TextStyle(
                                    fontSize: 13, color: HexColor("#333333")))
                          ]),
                    ),
                    Container(
                      height: 4,
                    ),
                    Container(
                      color: HexColor("#1FB9C7").withOpacity(0.08),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text("第一期",
                          style: TextStyle(
                              fontSize: 12, color: HexColor("#5C4304"))),
                    ),
                  ],
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "管理费：",
                    style: TextStyle(fontSize: 10, color: HexColor("#999999")),
                  ),
                  Text(
                    contractNodeItem.announcement ?? "10%",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: HexColor("#333333")),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "描   述：",
                    style: TextStyle(fontSize: 10, color: HexColor("#999999")),
                  ),
                  Flexible(
                    child: Text(
                      contractNodeItem.announcement ??
                          "大家快来参与我的节点吧，收益高高，收益真的很高，",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 11, color: HexColor("#333333")),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: Divider(height: 1, color: Color(0x2277869e)),
            ),
            Row(
              children: <Widget>[
                isNotFull
                    ? RichText(
                        text: TextSpan(
                            text: S.of(context).remain,
                            style: TextStyles.textC9b9b9bS12,
                            children: <TextSpan>[
                              TextSpan(
                                  text:
                                      "${FormatUtil.formatNum(int.parse(contractNodeItem.remainDelegation ?? "10000"))}",
                                  style: TextStyles.textC7c5b00S12),
                              TextSpan(
                                  text: "HYN",
                                  style: TextStyles.textC9b9b9bS12),
                            ]),
                      )
                    : RichText(
                        text: TextSpan(
                            text: fullDesc,
                            style: TextStyles.textC9b9b9bS12,
                            children: <TextSpan>[]),
                      ),
                Spacer(),
                Text(
                  "2020/12/12 12:12",
                  style: TextStyle(fontSize: 12, color: HexColor("#9B9B9B")),
                ),
                Visibility(
                  visible: false,
                  child: SizedBox(
                    height: 30,
//                width: 80,
                    child: FlatButton(
                      color: HexColor("#FF15B2D2"),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      onPressed: () {
                        Application.router.navigateTo(
                            context,
                            Routes.map3node_contract_detail_page +
                                "?contractId=${contractNodeItem.id}");
                      },
                      child: Text(
                          isPending
                              ? S.of(context).check_join
                              : S.of(context).detail,
                          style: TextStyle(fontSize: 13, color: Colors.white)),
                      //style: TextStyles.textC906b00S13),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}
