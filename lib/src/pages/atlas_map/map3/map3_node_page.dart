import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:sprintf/sprintf.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/data/cache/memory_cache.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/widget/node_active_contract_widget.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/map3_nodes_widget.dart';
import 'map3_node_create_wallet_page.dart';
import 'map3_node_list_page.dart';
import 'map3_node_public_widget.dart';

class Map3NodePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Map3NodeState();
  }
}

class _Map3NodeState extends State<Map3NodePage> with AutomaticKeepAliveClientMixin {
  LoadDataBloc loadDataBloc = LoadDataBloc();
  AtlasApi _atlasApi = AtlasApi();
  int _currentPage = 0;
  List<Map3InfoEntity> _lastActiveList = [];
  List<Map3InfoEntity> _myList = [];
  List<Map3InfoEntity> _pendingList = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    if (!MemoryCache.hasNodePageData) {
      loadDataBloc.add(LoadingEvent());
    } else {
      getNetworkData();
    }

    // todo: test_jison_0813
    /*
    for (int i = 0; i < 3; i++) {
      Map3InfoEntity item = Map3InfoEntity.onlyId(i);
      _myList.add(item);
      _lastActiveList.add(item);
      _pendingList.add(item);
    }*/
  }

  @override
  void dispose() {
    loadDataBloc.close();
    super.dispose();
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Container(
      child: LoadDataContainer(
        enablePullUp: _pendingList.isNotEmpty,
        //enablePullUp: (_nodePageEntityVo.contractNodeList != null && _nodePageEntityVo.contractNodeList.length > 0),
        bloc: loadDataBloc,
        onLoadData: () async {
          getNetworkData();
        },
        onRefresh: () {
          getNetworkData();
        },
        onLoadingMore: () {
          getNetworkData();
        },
        child: CustomScrollView(
          slivers: <Widget>[
            _map3HeadWidget(),
            _sectionTitleWidget(title: "我的节点", hasMore: _myList.isNotEmpty, isMine: true),
            _myNodeListWidget(),
            _sectionTitleWidget(title: "最新启动的节点", hasMore: _lastActiveList.isNotEmpty),
            _lastActiveWidget(),
            _sectionTitleWidget(title: S.of(context).wait_start_node_contract, hasMore: false),
            _pendingListWidget(),
          ],
        ),
      ),
    );
  }


  void getNetworkData() async {
    try {

      List<Map3InfoEntity> contractNodeList = await _atlasApi.postMap3NodeList(
        'address',
        page: _currentPage,
        size: 30,
      );
      
      if (contractNodeList.length > 0) {
        _lastActiveList = contractNodeList;
        _myList = contractNodeList;
        _pendingList = contractNodeList;

        loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        loadDataBloc.add(LoadMoreEmptyEvent());
      }
      setState(() {});
    } catch (e) {
      loadDataBloc.add(LoadMoreFailEvent());
    }
  }

  Widget _myNodeListWidget() {
    if (_myList.isEmpty) {
      return _emptyListWidget(title: "没有我的节点，您可以创建节点");
    }

    return SliverToBoxAdapter(
      child: NodeActiveContractWidget(
        contractList: _myList,
      ),
    );
  }

  Widget _lastActiveWidget() {
    if (_lastActiveList.isEmpty) {
      return _emptyListWidget(title: "没有最新启动的节点，您可以创建节点");
    }

    return SliverToBoxAdapter(
      child: NodeActiveContractWidget(
        contractList: _lastActiveList,
      ),
    );
  }

  Widget _pendingListWidget() {
    if (_pendingList.isEmpty) {
      return _emptyListWidget(title: S.of(context).no_pengding_node_contract_hint);
    }

    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      return Container(color: Colors.white, child: getMap3NodeWaitItem(context, _pendingList[index]));
    }, childCount: _pendingList.length));
  }

  Widget _sectionTitleWidget({String title, bool hasMore = true, bool isMine = false}) {
    return SliverToBoxAdapter(
      child: InkWell(
        onTap: () {
          if (isMine) {
            Application.router.navigateTo(context, Routes.map3node_my_page);
          } else {
            Application.router.navigateTo(
                context,
                Routes.map3node_list_page +
                    "?title=${Uri.encodeComponent(title)}&active=${MyContractType.active.index}");
          }
        },
        child: Container(
          padding: const EdgeInsets.only(left: 15.0, right: 15, top: 16),
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w500, color: HexColor("#000000")),
              )),
              Visibility(
                visible: hasMore,
                child: Text(
                  "查看更多",
                  style: TextStyles.textC999S12,
                ),
              ),
              Visibility(
                visible: hasMore,
                child: Icon(
                  Icons.chevron_right,
                  color: DefaultColors.color999,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyListWidget({String title = ""}) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
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
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              width: 160,
            ),
          ],
        ),
      ),
    );
  }

  Widget _nodesMapWidget() {
    // todo: test_jison
    int instanceCount = 10;

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
                      sprintf(
                          S.of(context).earth_outpace_server_node, [instanceCount]),
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

  Widget _map3HeadWidget() {

    // todo: test_jison
    var title = "";
    var desc = "Map3已开放云节点抵押，通过创建和委托抵押合约有效提升服务质量和网络安全，提供全球去中心化地图服务。节点参与者将在合约到期后按抵押量获得奖励。";
    var guideTitle = "开通教程";
    return SliverToBoxAdapter(
      child: Container(
        //color: Color(0xfff4f4f4),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            _nodesMapWidget(),
            Container(
              color: Colors.white24,
              margin: const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 16),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(title,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500, color: DefaultColors.colorcc000000)),
                        Spacer(),
                        InkWell(
                          onTap: _pushWebViewAction,
                          child: Text(guideTitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: DefaultColors.color66000000,
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
                            child: Image.asset("res/drawable/ic_map3_node_item_2.png",
                                width: 80, height: 80, fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        SizedBox(width: 16),
                        Flexible(
                          child: Text(desc,
                              style: TextStyle(fontSize: 12, height: 1.7, color: DefaultColors.color99000000)),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ClickOvalButton(S.of(context).create_contract, () {
                      _pushCreateContractAction();
                    }),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _pushWebViewAction() {
    // todo: test_jison_0604
    String webUrl = FluroConvertUtils.fluroCnParamsEncode("http://baidu.com");
    String webTitle = FluroConvertUtils.fluroCnParamsEncode("如何新开Map3节点");
    Application.router.navigateTo(context, Routes.toolspage_webview_page + '?initUrl=$webUrl&title=$webTitle');
  }

  Future _pushCreateContractAction() async {
    // 0.检查是否创建了HYN钱包
    var walletList = await WalletUtil.scanWallets();

    if (walletList.length == 0) {
      Application.router.navigateTo(context,
          Routes.map3node_create_wallet + "?pageType=${Map3NodeCreateWalletPage.CREATE_WALLET_PAGE_TYPE_CREATE}");
    } else {
      // 1.push预创建
      await Application.router.navigateTo(context, Routes.map3node_introduction_page + "?contractId=${2}");
    }

    // 2.创建成功回调的处理
    final result = ModalRoute.of(context).settings?.arguments;
    print("[detail] -----> back, _broadcaseContractAction, result:$result");
    // 记得清理
    if (result != null && result is Map) {
      var item = result["result"];
      if (item is ContractNodeItem) {
        // 3.push合约详情
        _pushContractDetail(item);
      }

      result["result"] = null;
    }
  }

  Future _pushContractDetail(ContractNodeItem contractNodeItem) async {

    Application.router.navigateTo(context, Routes.map3node_contract_detail_page + "?contractId=2");
  }
}

