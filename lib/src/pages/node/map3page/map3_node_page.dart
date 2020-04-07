import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/node_head_entity.dart';
import 'package:titan/src/pages/node/model/node_page_entity_vo.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
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
  NodePageEntityVo _nodePageEntityVo = NodePageEntityVo(null,List());
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
      color: Color(0xff194772),
      child: LoadDataContainer(
        bloc: loadDataBloc,
        onLoadData: () async {
          getNetworkData();
        },
        onRefresh: () {
          getNetworkData();
        },
        onLoadingMore: (){
          getMoreNetworkData();
        },
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(child: _map3HeadItem()),
            SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              return _getMap3NodeWaitItem(context, _nodePageEntityVo.contractNodeList[index]);
            }, childCount: _nodePageEntityVo.contractNodeList.length))
          ],
        ),
      ),
    );
  }

  void getNetworkData() async {
    try{
      currentPage = 0;
      _nodePageEntityVo = await _nodeApi.getNodePageEntityVo();
//      Future.delayed(Duration(seconds: 1), () {
        loadDataBloc.add(RefreshSuccessEvent());
        setState(() {
        });
//      });
    }catch(e){
      loadDataBloc.add(LoadFailEvent());
    }
  }

  void getMoreNetworkData() async {
    try{
      currentPage = currentPage + 1;
      List<ContractNodeItem> contractNodeList = await _nodeApi.getContractPendingList(currentPage);
      if(contractNodeList.length > 0){
        _nodePageEntityVo.contractNodeList.addAll(contractNodeList);
        loadDataBloc.add(LoadingMoreSuccessEvent());
      }else{
        loadDataBloc.add(LoadMoreEmptyEvent());
      }
      setState(() {
      });
    }catch(e){
      loadDataBloc.add(LoadMoreFailEvent());
    }
  }

  Widget _map3HeadItem() {
    if(_nodePageEntityVo.nodeHeadEntity == null){
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Stack(
            children: <Widget>[
              _controller.value.initialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : Container(),
//              Align(
//                  alignment: Alignment.topRight,
//                  child: Padding(
//                    padding: const EdgeInsets.all(10.0),
//                    child: Text(
//                      "MAP3更多介绍",
//                      style: TextStyles.textCfffS14,
//                    ),
//                  )),
              Positioned(
                  left: 0,
                  right: 0,
                  bottom: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      _nodePageEntityVo.nodeHeadEntity.message,
                      style: TextStyle(fontSize: 12, color: Colors.white60),
                    ),
                  ))
            ],
          ),
        ),
        Card(
          color: Colors.white54,
          margin:
              const EdgeInsets.only(left: 8.0, right: 8, top: 16, bottom: 16),
//          padding: const EdgeInsets.only(left:10.0,right: 10,top: 5,bottom: 5),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 8.0, right: 8, top: 8, bottom: 8),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    ClipRRect(
                      child: Image.asset(
                        "res/drawable/ic_map3_node_item.png",
                        width: 80,
                        height: 80,
                        fit:BoxFit.cover
                      ),
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
                                  child: Text("${_nodePageEntityVo.nodeHeadEntity.node.name}",
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white))),
                              InkWell(
                                onTap: (){
                                  String webUrl = FluroConvertUtils.fluroCnParamsEncode("http://baidu.com");
                                  String webTitle = FluroConvertUtils.fluroCnParamsEncode("如何新开Map3节点");
                                  Application.router.navigateTo(context, Routes.toolspage_webview_page
                                      + '?initUrl=$webUrl&title=$webTitle');
//                                  Navigator.push(
//                                      context,
//                                      MaterialPageRoute(
//                                          builder: (context) => WebViewContainer(
//                                            initUrl: "http://baidu.com",
//                                            title: "如何新开Map3节点",
//                                          )));
                                },
                                child: Text("开通教程", style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.lightGreenAccent,
                                    decoration: TextDecoration.underline)),
                              )
                            ],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 8),
                            child: Text(
                                "    ${_nodePageEntityVo.nodeHeadEntity.node.content}",
                                style: TextStyle(fontSize: 13, color: Colors.white)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                MaterialButton(
                  color: Colors.white,
                  onPressed: () {
                    Application.router.navigateTo(context,Routes.map3node_product_list);
                  },
                  child: Text("创建合约", style: TextStyles.textC26ac29S14),
                )
              ],
            ),
          ),
        ),
        Padding(
            padding:
                const EdgeInsets.only(left: 5.0, right: 5, top: 10, bottom: 10),
            child: Text("等待启动的节点抵押合约", style: TextStyles.textCfffS14))
      ],
    );
  }

  Widget _getMap3NodeWaitItem(BuildContext context, ContractNodeItem contractNodeItem) {
    String startAccount = "发起账户 ${contractNodeItem.ownerName} ${contractNodeItem.owner}";
    startAccount = startAccount.substring(0,startAccount.length > 25 ? 25 : startAccount.length);
    startAccount = startAccount + "...";
    return Card(
      color: Colors.white54,
      margin: const EdgeInsets.only(left: 5.0, right: 5, bottom: 5),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 10.0, right: 10, top: 5, bottom: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Image.asset(
                    "res/drawable/ic_map3_node_item.png",
                    width: 50,
                    height: 50,
                    fit:BoxFit.cover,
                  ),
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
                                  style: TextStyles.textCfffS14)),
                          Text("剩余3天启动", style: TextStyles.textCfffS12)
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                child: Text("$startAccount",
                                    style: TextStyles.textCfffS12,maxLines:1,softWrap: true)),
                            SizedBox(width: 10,),
                            RichText(
                              text: TextSpan(
                                  text: "还差",
                                  style: TextStyles.textCfffS12,
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: "${FormatUtil.formatNum(contractNodeItem.remainDelegation)}",
                                        style: TextStyles.textCf29a6eS12),
                                    TextSpan(
                                        text: "HYN",
                                        style: TextStyles.textCfffS12),
                                  ]),
                            ),
                          ],
                        ),
                      ),
                      Text("${FormatUtil.formatDate(contractNodeItem.instanceStartTime)}", style: TextStyles.textCfffS12),
                    ],
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Center(
                                child: Column(
                                  children: <Widget>[
                                    Text("${FormatUtil.formatPercent(contractNodeItem.contract.annualizedYield)}", style: TextStyles.textCfffS12),
                                  ],
                                )),
                          ),
                          Expanded(
                            child: Center(
                                child: Column(
                                  children: <Widget>[
                                    Text("${contractNodeItem.contract.duration}天", style: TextStyles.textCfffS12),
                                  ],
                                )),
                          ),
                          Expanded(
                            child: Center(
                                child: Column(
                                  children: <Widget>[
                                    Text("${FormatUtil.formatPercent(contractNodeItem.contract.commission)}", style: TextStyles.textCfffS12),
                                  ],
                                )),
                          ),
                      ],),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Center(
                                child: Column(
                                  children: <Widget>[
                                    Text("年化奖励", style: TextStyles.textCfffS12)
                                  ],
                                )),
                          ),
                          Expanded(
                            child: Center(
                                child: Column(
                                  children: <Widget>[
                                    Text("合约周期", style: TextStyles.textCfffS12)
                                  ],
                                )),
                          ),
                          Expanded(
                            child: Center(
                                child: Column(
                                  children: <Widget>[
                                    Text("管理费", style: TextStyles.textCfffS12)
                                  ],
                                )),
                          ),
                        ],)
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: MaterialButton(
                    color: Colors.white,
                    onPressed: () {
                      Application.router.navigateTo(context, Routes.map3node_join_contract_page
                          + "?contractId=${contractNodeItem.id}");
                    },
                    child: Text("参与", style: TextStyles.textC26ac29S12),
                  ),
                ),
              ],
            )
            /*Row(
              children: <Widget>[
                Expanded(
                  child: Center(
                      child: Column(
                    children: <Widget>[
                      Text("${FormatUtil.formatPercent(contractNodeItem.contract.annualizedYield)}", style: TextStyles.textCfffS12),
                      Text("年化奖励", style: TextStyles.textCfffS12)
                    ],
                  )),
                ),
                Expanded(
                  child: Center(
                      child: Column(
                    children: <Widget>[
                      Text("${contractNodeItem.contract.duration}月", style: TextStyles.textCfffS12),
                      Text("合约周期", style: TextStyles.textCfffS12)
                    ],
                  )),
                ),
                Expanded(
                  child: Center(
                      child: Column(
                    children: <Widget>[
                      Text("${FormatUtil.formatPercent(contractNodeItem.contract.commission)}", style: TextStyles.textCfffS12),
                      Text("管理费", style: TextStyles.textCfffS12)
                    ],
                  )),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: MaterialButton(
                        color: Colors.white,
                        onPressed: () {
                          Application.router.navigateTo(context, Routes.map3node_create_join_contract_page
                              + "?pageType=${Map3NodeCreateJoinContractPage.CONTRACT_PAGE_TYPE_JOIN}"
                          + "&contractId=${contractNodeItem.id}");
                        },
                        child: Text("参与", style: TextStyles.textC26ac29S12),
                      )),
                )
              ],
            )*/
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
