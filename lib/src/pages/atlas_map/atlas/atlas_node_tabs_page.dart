import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/atlas/atlas_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/memory_cache.dart';
import 'package:titan/src/pages/app_tabbar/bloc/bloc.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_home_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_home_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_introduce_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_staking_entity.dart';
import 'package:titan/src/pages/atlas_map/event/node_event.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_create_wallet_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_list_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_nodes_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/atlas_map/widget/atlas_info_widget.dart';
import 'package:titan/src/pages/atlas_map/widget/node_active_contract_widget.dart';
import 'package:titan/src/pages/node/model/node_head_entity.dart';
import 'package:titan/src/pages/skeleton/skeleton_map3_node_page.dart';
import 'package:titan/src/pages/skeleton/skeleton_node_tabs_content.dart';
import 'package:titan/src/pages/skeleton/skeleton_node_tabs_page.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/atlas_map_widget.dart';
import 'package:titan/src/widget/clip_tab_bar.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/map3_nodes_widget.dart';

import 'atlas_node_detail_item.dart';

enum NodeTab { map3, atlas }

class AtlasNodeTabsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AtlasNodeTabsPageState();
  }
}

class _AtlasNodeTabsPageState extends State<AtlasNodeTabsPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController _tabController;
  StreamSubscription _eventBusSubscription;

  LoadDataBloc _loadDataBloc = LoadDataBloc();

  get _isNoWallet => _address.isEmpty;
  var _address = "";

  NodeTab _selectedNodeTab = NodeTab.map3;

  ///Atlas
  AtlasHomeEntity _atlasHomeEntity;
  List<AtlasInfoEntity> _atlasNodeList = List();
  AtlasApi _atlasApi = AtlasApi();

  ///Map3
  Map3HomeEntity _map3homeEntity;
  List<Map3InfoEntity> _lastActiveList = [];
  List<Map3InfoEntity> _myList = [];
  List<Map3InfoEntity> _pendingList = [];
  Map3StakingEntity _map3stakingEntity;
  Map3IntroduceEntity _map3introduceEntity;

  bool _isShowLoading = true;
  int _currentPage = 1;
  int _pageSize = 10;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _tabController = new TabController(initialIndex: 0, vsync: this, length: 2);
    super.initState();
    _listenEventBus();
    _loadDataBloc.add(LoadingEvent());
    var activatedWallet =
        WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
    _address = activatedWallet?.wallet?.getAtlasAccount()?.address ?? "";
  }

  _listenEventBus() {
    _eventBusSubscription = Application.eventBus.on().listen((event) async {
      if (event is UpdateMap3TabsPageIndexEvent) {
        this.setState(() {
          _tabController.index = event.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _loadDataBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppTabBarBloc, AppTabBarState>(
      listener: (context, state) {
        if (state is ChangeNodeTabBarItemState) {
          this.setState(() {
            _tabController.index = state.index;
          });
        }
      },
      child: Scaffold(
        body: Container(
          color: Colors.white,
          child: LoadDataContainer(
              bloc: _loadDataBloc,
              onRefresh: () {
                setState(() {
                  _isShowLoading = true;
                });
                if (_selectedNodeTab == NodeTab.atlas) {
                  _refreshAtlasData();
                } else {
                  _map3OnLoadData();
                }
              },
              onLoadData: () {
                _isShowLoading = true;
                if (_selectedNodeTab == NodeTab.atlas) {
                  _refreshAtlasData();
                } else {
                  _map3OnLoadData();
                }
              },
              onLoadingMore: () {
                _isShowLoading = true;
                if (_selectedNodeTab == NodeTab.atlas) {
                  _loadMoreAtlasData();
                } else {
                  _map3OnLoadingMore();
                }
              },
              showLoadingWidget: false,
              enablePullUp: !_isShowLoading,
              child: CustomScrollView(
                slivers: _slivers(),
              )),
        ),
      ),
    );
  }

  List<Widget> _slivers() {
    List<Widget> slivers = [
      SliverToBoxAdapter(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              child: Image.asset(
                'res/drawable/bg_node_page_header.png',
                fit: BoxFit.fitWidth,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: AtlasInfoWidget(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Container(
                    height: 150,
                  ),
                  Stack(
                    children: [
                      _tabBar(),
                      Column(
                        children: [
                          Container(
                            height: 49.5,
                          ),
                          _mapWidget()
                        ],
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ];

    if (_isShowLoading) {
      slivers.add(SliverToBoxAdapter(
        child: SkeletonNodeTabsContent(),
      ));
    } else {
      slivers.addAll(
        _selectedNodeTab == NodeTab.map3
            ? _map3NodePageSlivers()
            : _atlasNodePageSlivers(),
      );
    }
    return slivers;
  }

  _nodeTab({
    @required bool selected,
    @required String logoPath,
    @required String name,
  }) {
    return Wrap(
      children: [
        Image.asset(
          logoPath,
          width: 20.0,
          height: 20.0,
          color: selected ? Theme.of(context).primaryColor : Colors.white,
        ),
        SizedBox(
          width: 8.0,
        ),
        Text(
          name,
          style: TextStyle(
            color: selected ? Theme.of(context).primaryColor : Colors.white,
            fontSize: 18.0,
          ),
        )
      ],
    );
  }

  _tabBar() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: ClipTabBar(
            children: [
              _nodeTab(
                selected: _selectedNodeTab == NodeTab.map3,
                logoPath: 'res/drawable/ic_map3_logo.png',
                name: 'Map3',
              ),
              _nodeTab(
                selected: _selectedNodeTab == NodeTab.atlas,
                logoPath: 'res/drawable/ic_atlas_logo.png',
                name: 'Atlas',
              ),
            ],
            onTabChanged: (nodeTab) {
              setState(() {
                if (_selectedNodeTab != nodeTab) {
                  _isShowLoading = true;
                  _loadDataBloc.add(LoadingEvent());
                }
                _selectedNodeTab = nodeTab;
              });
            },
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 50,
          child: Row(
            children: [
              Expanded(
                child: Container(
                    color: _selectedNodeTab == NodeTab.map3
                        ? Colors.white
                        : Colors.black.withOpacity(0.5)),
              ),
              Expanded(
                child: Container(
                  color: _selectedNodeTab == NodeTab.atlas
                      ? Colors.white
                      : Colors.black.withOpacity(0.5),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  _skeletonMap() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(
          16.0,
        )),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[100],
          enabled: true,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
              width: double.infinity,
              height: 162,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  _mapWidget() {
    if (_isShowLoading) {
      return _skeletonMap();
    } else {
      return _selectedNodeTab == NodeTab.map3 ? _map3Map() : _atlasMap();
    }
  }

  List<Widget> _map3NodePageSlivers() {
    List<Widget> slivers = [
      _nodeIntroduceWidget(),
      _sectionTitleWidget(
          title: S.of(context).my_nodes, hasMore: true, isMine: true),
      _myNodeListWidget(),
      _sectionTitleWidget(
          title: S.of(context).lastest_launched_nodes,
          hasMore: _lastActiveList.isNotEmpty),
      _lastActiveWidget(),
      _sectionTitleWidget(
          title: S.of(context).wait_start_node_contract, hasMore: false),
      _pendingListWidget(),
    ];
    return slivers;
  }

  _nodeIntroduceWidget() {
    var title = _map3introduceEntity?.name ?? S.of(context).map3_nodes_v1;
    var desc = S.of(context).map3_introduction;
    var guideTitle = S.of(context).tutorial;
    return SliverToBoxAdapter(
      child: Container(
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
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: DefaultColors.colorcc000000)),
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
                _pushCreateContractAction();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitleWidget({
    String title,
    bool hasMore = true,
    bool isMine = false,
  }) {
    return SliverToBoxAdapter(
      child: InkWell(
        onTap: () {
          if (isMine) {
            if (_isNoWallet) {
              _pushWalletManagerAction();
              return;
            }
            Application.router.navigateTo(context, Routes.map3node_my_page);
          } else {
            if (!hasMore) return;

            Application.router.navigateTo(
                context,
                Routes.map3node_list_page +
                    "?title=${Uri.encodeComponent(title)}&active=${MyContractType.active.index}");
          }
        },
        child: Container(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.w500, color: HexColor("#000000")),
              )),
              Visibility(
                visible: hasMore,
                child: Text(
                  isMine
                      ? S.of(context).check_reward
                      : S.of(context).check_more,
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

  Widget _myNodeListWidget() {
    if (_myList.isEmpty) {
      return emptyListWidget(
          title: _address.isEmpty
              ? S.of(context).check_after_has_wallet
              : S.of(context).my_nodes_empty);
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: NodeActiveContractWidget(
          contractList: _myList,
        ),
      ),
    );
  }

  Widget _lastActiveWidget() {
    if (_lastActiveList.isEmpty) {
      return emptyListWidget(title: S.of(context).no_lastest_active_nodes);
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: NodeActiveContractWidget(
          contractList: _lastActiveList,
        ),
      ),
    );
  }

  Widget _pendingListWidget() {
    if (_pendingList.isEmpty) {
      return emptyListWidget(
          title: S.of(context).no_pengding_node_contract_hint);
    }

    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      return Container(
        color: Colors.white,
        child: getMap3NodeWaitItem(
          context,
          _pendingList[index],
          _map3introduceEntity,
          canCheck: (index < _map3stakingEntity.canStakingNum),
          currentEpoch:
              AtlasInheritedModel.of(context).atlasHomeEntity?.info?.epoch,
        ),
      );
    }, childCount: _pendingList.length));
  }

  void _pushWebViewAction() {
    AtlasApi.goToAtlasMap3HelpPage(context);
  }

  Future _pushCreateContractAction() async {
    // 0.检查是否创建了HYN钱包
    var walletList = await WalletUtil.scanWallets();

    if (walletList.length == 0) {
      Application.router.navigateTo(
          context,
          Routes.map3node_create_wallet +
              "?pageType=${Map3NodeCreateWalletPage.CREATE_WALLET_PAGE_TYPE_CREATE}");
    } else {
      // 1.push预创建
      await Application.router
          .navigateTo(context, Routes.map3node_introduction_page);
    }

    // 2.创建成功回调的处理
    final result = ModalRoute.of(context).settings?.arguments;
    print("[detail] -----> back, _broadcaseContractAction, result:$result");
    // 记得清理
    if (result != null && result is Map) {
      var entity = result["result"];
      if (entity is Map3InfoEntity) {
        // 3.push合约详情
        _pushContractDetail(entity);
      }

      result["result"] = null;
    }
  }

  Future _pushContractDetail(Map3InfoEntity infoEntity) async {
    Application.router.navigateTo(
      context,
      Routes.map3node_contract_detail_page +
          '?info=${FluroConvertUtils.object2string(infoEntity.toJson())}',
    );
  }

  List<Widget> _atlasNodePageSlivers() {
    List<Widget> slivers = [
      SliverToBoxAdapter(
        child: _atlasIntro(),
      ),
      SliverToBoxAdapter(
        child: _createAtlasNode(),
      ),
      SliverToBoxAdapter(
        child: _myAtlasNodes(),
      ),
      SliverToBoxAdapter(
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Text(
                '节点列表',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      _atlasNodeListView(),
    ];
    return slivers;
  }

  ///Atlas
  ///

  _atlasIntro() {
    var title = S.of(context).atlas_node;
    var desc = S.of(context).atlas_node_intro;
    var guideTitle = S.of(context).tutorial;
    return Container(
      margin: const EdgeInsets.only(
        left: 15,
        right: 15,
        top: 8,
        bottom: 16,
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: DefaultColors.colorcc000000)),
                Spacer(),
                InkWell(
                  onTap: () {},
                  child: Text(guideTitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: DefaultColors.color66000000,
                      )),
                )
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                child: Image.asset("res/drawable/ic_atlas_node_item.png",
                    width: 80, height: 80, fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(4.0),
              ),
              SizedBox(
                width: 16,
              ),
              Flexible(
                child: Text(desc,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.7,
                      color: DefaultColors.color99000000,
                    )),
              )
            ],
          ),
        ],
      ),
    );
  }

  _map3Map() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(
          16.0,
        )),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(16.0),
      height: 180,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          children: <Widget>[
            Map3NodesWidget(_map3homeEntity?.points),
            Positioned(
              left: 16,
              bottom: 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    S.of(context).map3_nodes,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      shadows: [
                        BoxShadow(
                          offset: const Offset(1.0, 1.0),
                          blurRadius: 2.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    S.of(context).map_provide_stable_server,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      shadows: [
                        BoxShadow(
                          offset: const Offset(1.0, 1.0),
                          blurRadius: 2.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _atlasMap() {
    var points = json.decode(
      AtlasInheritedModel.of(context).atlasHomeEntity?.points ?? '[]',
    );
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(
          16.0,
        )),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(16.0),
      height: 180,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          children: <Widget>[
            AtlasMapWidget(points),
            Positioned(
              left: 16,
              bottom: 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    S.of(context).atlas_consensus_node,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      shadows: [
                        BoxShadow(
                          offset: const Offset(1.0, 1.0),
                          blurRadius: 2.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    S.of(context).consensus_guarantee_for_hyberion,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      shadows: [
                        BoxShadow(
                          offset: const Offset(1.0, 1.0),
                          blurRadius: 2.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _createAtlasNode() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0.0, bottom: 0),
          child: Container(
            width: double.infinity,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 2,
                  child: ClickOvalButton(
                    S.of(context).atlas_create_node,
                    () {
                      Application.router.navigateTo(
                        context,
                        Routes.atlas_create_node_page,
                      );
                    },
                    fontSize: 16,
                    isLoading: true,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              S.of(context).not_open_please_wait,
              style: TextStyle(
                fontSize: 12,
                color: DefaultColors.color999,
              ),
            ),
          ),
        )
      ],
    );
  }

  _myAtlasNodes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 16,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                S.of(context).my_nodes,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  if (_isNoWallet) {
                    _pushWalletManagerAction();
                    return;
                  }

                  Application.router.navigateTo(
                    context,
                    Routes.atlas_my_node_page,
                  );
                },
                child: Text(
                  S.of(context).check_more,
                  style: TextStyle(
                    color: DefaultColors.color999,
                    fontSize: 12,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: DefaultColors.color999,
                size: 12,
              )
            ],
          ),
        ),
        _atlasHomeEntity?.atlasHomeNodeList?.isNotEmpty ?? false
            ? Container(
                height: 150,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _atlasHomeEntity?.atlasHomeNodeList?.length ?? 0,
                    itemBuilder: (context, index) {
                      return _atlasNodeInfoItem(index);
                    }),
              )
            : _emptyListHint(),
      ],
    );
  }

  _atlasNodeInfoItem(int index) {
    var node = _atlasHomeEntity?.atlasHomeNodeList[index];
    return InkWell(
      onTap: () {
        Application.router.navigateTo(
          context,
          Routes.atlas_detail_page +
              '?atlasNodeId=${FluroConvertUtils.fluroCnParamsEncode(node?.nodeId)}&atlasNodeAddress=${FluroConvertUtils.fluroCnParamsEncode(node?.address)}',
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 16.0),
        child: Stack(
          children: <Widget>[
            Container(
              width: 105,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[200],
                    blurRadius: 15.0,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  iconAtlasHomeNodeWidget(
                      _atlasHomeEntity?.atlasHomeNodeList[index]),
                  SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0, right: 5),
                    child: Text(
                        _atlasHomeEntity?.atlasHomeNodeList[index]?.name ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: HexColor("#333333"),
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 8,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Image.asset(
                    'res/drawable/ic_atlas_node_rank_bg.png',
                    width: 20,
                    height: 20,
                  ),
                  Text(
                    '${index + 1}',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _emptyListHint() {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              'res/drawable/ic_empty_contract.png',
              width: 100,
              height: 100,
            ),
          ),
          Text(
            S.of(context).exchange_empty_list,
            style: TextStyle(
              fontSize: 13,
              color: DefaultColors.color999,
            ),
          ),
        ],
      ),
    );
  }

  _atlasNodeListView() {
    if (_atlasNodeList.isNotEmpty) {
      return SliverList(
          delegate: SliverChildBuilderDelegate(
        (context, index) {
          return AtlasNodeDetailItem(_atlasNodeList[index]);
        },
        childCount: _atlasNodeList.length,
      ));
    } else {
      return SliverToBoxAdapter(
        child: _emptyListHint(),
      );
    }
  }

  _map3OnLoadData() async {
    _currentPage = 1;
    print("[onLoadData] _currentPage ---> _currentPage : $_currentPage");

    try {
      var requestList = await Future.wait([
        _atlasApi.getMap3Home(_address),
        _atlasApi.getMap3StakingList(_address, page: _currentPage, size: 10),
        AtlasApi.getIntroduceEntity(),
      ]);

      _map3homeEntity = requestList[0];
      _map3stakingEntity = requestList[1];
      _map3introduceEntity = requestList[2];

      if (_map3stakingEntity != null) {
        _lastActiveList = _map3homeEntity.newStartNodes;
        _myList = _map3homeEntity.myNodes;
        _pendingList = _map3stakingEntity.map3Nodes;

        _loadDataBloc.add(RefreshSuccessEvent());
      } else {
        _loadDataBloc.add(LoadEmptyEvent());
      }
      setState(() {});
    } catch (e) {
      print(e);
      _loadDataBloc.add(RefreshFailEvent());
    }

    _isShowLoading = false;
    if (mounted) setState(() {});
  }

  _map3OnLoadingMore() async {
    try {
      Map3StakingEntity map3stakingEntity = await _atlasApi
          .getMap3StakingList(_address, page: _currentPage + 1, size: 10);

      if (map3stakingEntity != null && map3stakingEntity.map3Nodes.isNotEmpty) {
        List<Map3InfoEntity> lastPendingList = List.from(_pendingList);
        List<Map3InfoEntity> list = map3stakingEntity.map3Nodes;
        lastPendingList.addAll(list);

        _pendingList = lastPendingList;

        _currentPage++;

        _loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        _loadDataBloc.add(LoadMoreEmptyEvent());
      }
    } catch (e) {
      _loadDataBloc.add(LoadMoreFailEvent());
    }
    _isShowLoading = false;
    if (mounted) setState(() {});
  }

  _refreshAtlasData() async {
    _currentPage = 1;
    _atlasNodeList.clear();
    try {
      var _nodeList = await _atlasApi.postAtlasNodeList(
        WalletInheritedModel.of(context)
                ?.activatedWallet
                ?.wallet
                ?.getAtlasAccount()
                ?.address ??
            '',
        page: _currentPage,
        size: _pageSize,
      );

      if (_nodeList != null) {
        _atlasNodeList.clear();
        _atlasNodeList.addAll(_nodeList);
      }
      _loadDataBloc.add(RefreshSuccessEvent());
    } catch (e) {
      _loadDataBloc.add(RefreshFailEvent());
    }
    _isShowLoading = false;
    if (mounted) setState(() {});
  }

  _loadMoreAtlasData() async {
    try {
      var _nodeList = await _atlasApi.postAtlasNodeList(
        WalletInheritedModel.of(context)
                ?.activatedWallet
                ?.wallet
                ?.getAtlasAccount()
                ?.address ??
            '',
        page: _currentPage + 1,
        size: _pageSize,
      );

      if (_nodeList != null && _nodeList.isNotEmpty) {
        _atlasNodeList.addAll(_nodeList);
        _currentPage++;
        _loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        _loadDataBloc.add(LoadMoreEmptyEvent());
      }
    } catch (e) {
      _loadDataBloc.add(LoadMoreFailEvent());
    }
    _isShowLoading = false;
    if (mounted) setState(() {});
  }

  _pushWalletManagerAction() {
    Application.router.navigateTo(
        context,
        Routes.map3node_create_wallet +
            "?pageType=${Map3NodeCreateWalletPage.CREATE_WALLET_PAGE_TYPE_JOIN}");
  }
}
