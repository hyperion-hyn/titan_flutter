import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sprintf/sprintf.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/app_tabbar/bloc/bloc.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/node_head_entity.dart';
import 'package:titan/src/pages/node/model/node_page_entity_vo.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:video_player/video_player.dart';

import 'map3_node_create_contract_page.dart';

class Map3NodePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Map3NodeState();
  }
}

class _Map3NodeState extends State<Map3NodePage> {
  LoadDataBloc loadDataBloc = LoadDataBloc();
  VideoPlayerController _controller;
  NodeApi _nodeApi = NodeApi();
  NodePageEntityVo _nodePageEntityVo = NodePageEntityVo(null, List());
  int currentPage = 0;

  @override
  void initState() {
    _controller =
        VideoPlayerController.asset('res/drawable/ic_map3_node_head.mp4')
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {
//              _controller.setLooping(true);
              _controller.play();
            });
          });

    loadDataBloc.add(LoadingEvent());
//    getNetworkData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xfffdfdfd),
      child: LoadDataContainer(
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
            _pendingListWidget()
          ],
        ),
      ),
    );
  }

  void getNetworkData() async {
    try {
      currentPage = 0;
      _nodePageEntityVo = await _nodeApi.getNodePageEntityVo();
//      Future.delayed(Duration(seconds: 1), () {
      loadDataBloc.add(RefreshSuccessEvent());
      setState(() {});
//      });
    } catch (e) {
      setState(() {
        loadDataBloc.add(LoadFailEvent());
      });
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

  Widget _pendingListWidget(){
    if (_nodePageEntityVo.contractNodeList == null
        || _nodePageEntityVo.contractNodeList.length == 0) {
      return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15, top: 17, bottom: 11),
                    child: Text(S.of(context).wait_start_node_contract,
                        style: TextStyles.textCcc000000S16)),
                Container(
                    height: 260,
                    child: Center(child: Text(S.of(context).search_empty_data,style: TextStyle(fontSize: 15, color: HexColor("#999999")))))
              ],
            );
          }, childCount: 1));
//      return Center(
//        child: Text("暂无数据",style: TextStyle(fontSize: 11,color: HexColor("#999999")),),
//      );
    }
    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15, top: 17, bottom: 11),
                    child: Text(S.of(context).wait_start_node_contract,
                        style: TextStyles.textCcc000000S16)),
                _getMap3NodeWaitItem(
                    context, _nodePageEntityVo.contractNodeList[index])
              ],
            );
          }
          return _getMap3NodeWaitItem(
              context, _nodePageEntityVo.contractNodeList[index]);
        }, childCount: _nodePageEntityVo.contractNodeList.length));
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
                  style: TextStyle(fontSize: 20, color: Colors.white,fontWeight: FontWeight.bold),
                ),
                Text(
                  S.of(context).map_provide_stable_server,
                  style: TextStyle(fontSize: 12, color: HexColor("#e6ffffff")),
                ),
              ],
            ),
          ),
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            margin: const EdgeInsets.only(
                left: 15, right: 15, top: 127, bottom: 16),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 19, top: 13, bottom: 17),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      ClipRRect(
                        child: Image.asset(
                            "res/drawable/ic_map3_node_item_2.png",
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover),
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
                                    child: Text(
                                        "${_nodePageEntityVo.nodeHeadEntity.node.name}",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                DefaultColors.colorcc000000))),
                                /*InkWell(
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
                                          decoration:
                                              TextDecoration.underline)),
                                )*/
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8),
                              child: Text(
                                  "    ${_nodePageEntityVo.nodeHeadEntity.node.content}",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: DefaultColors.color99000000)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 24,
                    width: 92,
                    child: FlatButton(
                      color: DefaultColors.colorffdb58,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(36)),
                      onPressed: () {
                        Application.router
                            .navigateTo(context, Routes.map3node_product_list);
                      },
                      child: Text(S.of(context).create_contract, style: TextStyles.textC906b00S13),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _getMap3NodeWaitItem(
      BuildContext context, ContractNodeItem contractNodeItem) {
    if (contractNodeItem == null) return Container();

//    String startAccount = "${contractNodeItem.owner}";
//    startAccount = startAccount.substring(
//        0, startAccount.length > 25 ? 25 : startAccount.length);
//    startAccount = startAccount + "...";
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0))),
      color: Colors.white,
      margin: const EdgeInsets.only(left: 15.0, right: 15, bottom: 9),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20.0, right: 13, top: 7, bottom: 7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text("${contractNodeItem.ownerName}",
                    style: TextStyles.textCcc000000S14),
                Expanded(
                    child: Text(" ${UiUtil.shortEthAddress(contractNodeItem.owner)}",
                        style: TextStyles.textC9b9b9bS12)),
                Text(S.of(context).remain_day_has_colon(contractNodeItem.remainDay),
                    style: TextStyles.textC9b9b9bS12)
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Divider(height: 1, color: DefaultColors.color1177869e),
            ),
            InkWell(
              onTap: (){
                Application.router.navigateTo(context, Routes.map3node_contract_detail_page + "?contractId=${contractNodeItem.id}");
//                String jsonString = FluroConvertUtils.object2string(contractNodeItem.toJson());
//                Application.router.navigateTo(context, Routes.map3node_contract_detail_page + "?model=${jsonString}");
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
                                child: Text(
                                    "${contractNodeItem.contract.nodeName}",
                                    style: TextStyles.textCcc000000S14))
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                  S.of(context).highest + " ${FormatUtil.formatTenThousandNoUnit(contractNodeItem.contract.minTotalDelegation)}" + S.of(context).ten_thousand,
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
                      Text(
                          "${FormatUtil.formatPercent(contractNodeItem.contract.annualizedYield)}",
                          style: TextStyles.textCff4c3bS18),
                      Text(S.of(context).annualized_rewards, style: TextStyles.textC99000000S10)
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 9, bottom: 9),
              child: Divider(height: 1, color: DefaultColors.color1177869e),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: RichText(
                    text: TextSpan(
                        text: S.of(context).remain,
                        style: TextStyles.textC9b9b9bS12,
                        children: <TextSpan>[
                          TextSpan(
                              text:
                                  "${FormatUtil.formatNum(int.parse(contractNodeItem.remainDelegation))}",
                              style: TextStyles.textC7c5b00S12),
                          TextSpan(
                              text: "HYN", style: TextStyles.textC9b9b9bS12),
                        ]),
                  ),
                ),
                SizedBox(
                  height: 24,
                  width: 78,
                  child: FlatButton(
                    color: DefaultColors.colorffdb58,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    onPressed: () async {
                      var walletList = await WalletUtil.scanWallets();
                      if (walletList.length == 0) {
//                        Fluttertoast.showToast(msg: "请导入钱包");
//                        BlocProvider.of<AppTabBarBloc>(context)
//                            .add(ChangeTabBarItemEvent(index: 1));
                        Application.router.navigateTo(context, Routes.map3node_create_wallet);
                      } else {
                        Application.router.navigateTo(
                            context,
                            Routes.map3node_join_contract_page +
                                "?contractId=${contractNodeItem.id}");
                      }
                    },
                    child: Text(S.of(context).join, style: TextStyles.textC906b00S13),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    loadDataBloc.close();
    _controller.dispose();
    super.dispose();
  }
}
