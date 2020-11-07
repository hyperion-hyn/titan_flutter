import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/memory_cache.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_home_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_home_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_introduce_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_staking_entity.dart';
import 'package:titan/src/pages/atlas_map/widget/node_active_contract_widget.dart';
import 'package:titan/src/pages/skeleton/skeleton_map3_node_page.dart';
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

  final LoadDataBloc loadDataBloc;

  Map3NodePage({this.loadDataBloc});

  @override
  State<StatefulWidget> createState() {
    return _Map3NodeState();
  }
}

class _Map3NodeState extends BaseState<Map3NodePage> with AutomaticKeepAliveClientMixin {
  AtlasApi _atlasApi = AtlasApi();
  int _currentPage = 1;
  List<Map3InfoEntity> _lastActiveList = [];
  List<Map3InfoEntity> _myList = [];
  List<Map3InfoEntity> _pendingList = [];
  Map3HomeEntity _map3homeEntity;
  Map3StakingEntity _map3stakingEntity;
  Map3IntroduceEntity _map3introduceEntity;
  var _address = "";

  get _isNoWallet => _address.isEmpty;
  int _currentEpoch = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
    _address = activatedWallet?.wallet?.getEthAccount()?.address ?? "";

    if (!MemoryCache.hasNodePageData) {
      widget.loadDataBloc.add(LoadingEvent());
    } else {
      onLoadData();
    }
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Container(
      child: LoadDataContainer(
        enablePullUp: _pendingList.isNotEmpty,
        //enablePullUp: (_nodePageEntityVo.contractNodeList != null && _nodePageEntityVo.contractNodeList.length > 0),
        bloc: widget.loadDataBloc,
        onLoadData: () async {
          onLoadData();
        },
        onRefresh: () {
          onLoadData();
        },
        onLoadingMore: () {
          onLoadingMore();
        },
        onLoadSkeletonView: SkeletonMap3NodePage(),
        child: CustomScrollView(
          physics: NeverScrollableScrollPhysics(),
          slivers: <Widget>[
            _map3HeadWidget(),
            _sectionTitleWidget(title: S.of(context).my_nodes, hasMore: true, isMine: true),
            _myNodeListWidget(),
            _sectionTitleWidget(title: S.of(context).lastest_launched_nodes, hasMore: _lastActiveList.isNotEmpty),
            _lastActiveWidget(),
            _sectionTitleWidget(title: S.of(context).wait_start_node_contract, hasMore: false),
            _pendingListWidget(),
          ],
        ),
      ),
    );
  }

  void onLoadData() async {
    _currentPage = 1;
    print("[onLoadData] _currentPage ---> _currentPage : $_currentPage");

    try {
      var requestList = await Future.wait([
        _atlasApi.getMap3Home(_address),
        _atlasApi.getMap3StakingList(_address, page: _currentPage, size: 10),
        AtlasApi.getIntroduceEntity(),
        _atlasApi.postAtlasHome(_address),
      ]);

      _map3homeEntity = requestList[0];
      _map3stakingEntity = requestList[1];
      _map3introduceEntity = requestList[2];

      var _atlasHomeEntity = requestList[3] as AtlasHomeEntity;
      _currentEpoch = _atlasHomeEntity?.info?.epoch ?? 0;

      if (_map3stakingEntity != null) {
        _lastActiveList = _map3homeEntity.newStartNodes;
        _myList = _map3homeEntity.myNodes;
        _pendingList = _map3stakingEntity.map3Nodes;

        widget.loadDataBloc.add(RefreshSuccessEvent());
      } else {
        widget.loadDataBloc.add(LoadEmptyEvent());
      }
      setState(() {});
    } catch (e) {
      print(e);

      widget.loadDataBloc.add(RefreshFailEvent());
    }
  }

  void onLoadingMore() async {
    _currentPage++;

    print("[onLoadingMore] _currentPage ---> _currentPage : $_currentPage");

    try {
      Map3StakingEntity map3stakingEntity = await _atlasApi.getMap3StakingList(_address, page: _currentPage, size: 10);

      if (map3stakingEntity != null && map3stakingEntity.map3Nodes.isNotEmpty) {
        List<Map3InfoEntity> lastPendingList = List.from(_pendingList);
        List<Map3InfoEntity> list = map3stakingEntity.map3Nodes;
        lastPendingList.addAll(list);

        _pendingList = lastPendingList;

        widget.loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        widget.loadDataBloc.add(LoadMoreEmptyEvent());
      }
      setState(() {});
    } catch (e) {
      print(e);

      widget.loadDataBloc.add(LoadMoreFailEvent());
    }
  }

  Widget _myNodeListWidget() {
    if (_myList.isEmpty) {
      return emptyListWidget(title: _address.isEmpty ? S.of(context).check_after_has_wallet : S.of(context).my_nodes_empty);
    }

    return SliverToBoxAdapter(
      child: NodeActiveContractWidget(
        contractList: _myList,
      ),
    );
  }

  Widget _lastActiveWidget() {
    if (_lastActiveList.isEmpty) {
      return emptyListWidget(title: S.of(context).no_lastest_active_nodes);
    }

    return SliverToBoxAdapter(
      child: NodeActiveContractWidget(
        contractList: _lastActiveList,
      ),
    );
  }

  Widget _pendingListWidget() {
    if (_pendingList.isEmpty) {
      return emptyListWidget(title: S.of(context).no_pengding_node_contract_hint);
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
          currentEpoch: _currentEpoch,
        ),
      );
    }, childCount: _pendingList.length));
  }

  void _pushWalletManagerAction() {
    Application.router.navigateTo(
        context, Routes.map3node_create_wallet + "?pageType=${Map3NodeCreateWalletPage.CREATE_WALLET_PAGE_TYPE_JOIN}");
  }

  Widget _sectionTitleWidget({String title, bool hasMore = true, bool isMine = false}) {
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
                  isMine ? S.of(context).check_reward : S.of(context).check_more,
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

  Widget _nodesMapWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          width: double.infinity,
          height: 162,
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
      ),
    );
  }

  _nodeIntroduceWidget() {
    var title = _map3introduceEntity?.name ?? S.of(context).map3_nodes_v1;
    var desc = S.of(context).map3_introduction;
    var guideTitle = S.of(context).tutorial;
    return Container(
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: DefaultColors.colorcc000000)),
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
                    child:
                        Image.asset("res/drawable/ic_map3_node_item_2.png", width: 80, height: 80, fit: BoxFit.cover),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                SizedBox(width: 16),
                Flexible(
                  child: Text(desc, style: TextStyle(fontSize: 12, height: 1.7, color: DefaultColors.color99000000)),
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
    );
  }

  Widget _map3HeadWidget() {
    return SliverToBoxAdapter(
      child: Container(
        //color: Color(0xfff4f4f4),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            _nodesMapWidget(),
            _nodeIntroduceWidget(),
          ],
        ),
      ),
    );
  }

  void _pushWebViewAction() {
    AtlasApi.goToAtlasMap3HelpPage(context);
  }

  Future _pushCreateContractAction() async {
    // 0.检查是否创建了HYN钱包
    var walletList = await WalletUtil.scanWallets();

    if (walletList.length == 0) {
      Application.router.navigateTo(context,
          Routes.map3node_create_wallet + "?pageType=${Map3NodeCreateWalletPage.CREATE_WALLET_PAGE_TYPE_CREATE}");
    } else {
      // 1.push预创建
      await Application.router.navigateTo(context, Routes.map3node_introduction_page);
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
      Routes.map3node_contract_detail_page + '?info=${FluroConvertUtils.object2string(infoEntity.toJson())}',
    );
  }
}
