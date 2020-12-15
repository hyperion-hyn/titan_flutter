import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/atlas/atlas_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_my_node_list_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_node_detail_item.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_home_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/committee_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_create_wallet_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/skeleton/skeleton_atlas_node_page.dart';
import 'package:titan/src/pages/skeleton/skeleton_map3_node_page.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/atlas_map_widget.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class AtlasNodesPage extends StatefulWidget {
  final ScrollController scrollController;

  AtlasNodesPage({
    this.scrollController,
  });

  @override
  State<StatefulWidget> createState() {
    return AtlasNodesPageState();
  }
}

class AtlasNodesPageState extends State<AtlasNodesPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  ///
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  AtlasApi _atlasApi = AtlasApi();

  List<AtlasInfoEntity> _atlasNodeList = List();

  AtlasHomeEntity _atlasHomeEntity;

  ///load more for [_atlasNodeList]
  ///
  int _currentPage = 1;
  int _pageSize = 10;

  get _isNoWallet => _address.isEmpty;
  var _address = "";

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadDataBloc.add(LoadingEvent());

    var activatedWallet =
        WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
    _address = activatedWallet?.wallet?.getAtlasAccount()?.address ?? "";
  }

  _getData() async {
    _getAtlasHome();
  }

  _getAtlasHome() async {
    try {
      _atlasHomeEntity = await _atlasApi.postAtlasHome(
        WalletInheritedModel.of(context)
                ?.activatedWallet
                ?.wallet
                ?.getAtlasAccount()
                ?.address ??
            '',
      );
      setState(() {});
    } catch (e) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: LoadDataContainer(
          bloc: _loadDataBloc,
          enablePullUp: _atlasNodeList.isNotEmpty,
          onLoadData: () async {
            await _getData();
            await _refreshData();
          },
          onRefresh: () async {
            await _getData();
            await _refreshData();
          },
          onLoadingMore: () {
            _loadMoreData();
          },
          onLoadSkeletonView: SkeletonMap3NodePage(),
          child: CustomScrollView(
            controller: widget.scrollController,
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: _atlasInfo(),
              ),
              SliverToBoxAdapter(
                child: _atlasIntro(),
              ),
              SliverToBoxAdapter(
                child: _createNode(),
              ),
              SliverToBoxAdapter(
                child: _myNodes(),
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
              _atlasNodeListView()
            ],
          ),
        ),
      ),
    );
  }

  _atlasInfo() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(16.0),
          child: _atlasMap(),
        ),
      ],
    );
  }

  _atlasIntro() {
    var title = 'Atlas节点';
    var desc = 'Atlas网络层由Atlas节点组成，并按照抵押量降序选出88个出块节点进行验证、出块、清算、并获取出块奖励。';
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
//                InkWell(
//                  onTap: () {},
//                  child: Text(guideTitle,
//                      style: TextStyle(
//                        fontSize: 12,
//                        color: DefaultColors.color66000000,
//                      )),
//                )
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

  _atlasMap() {
    var points = json.decode(_atlasHomeEntity?.points ?? '[]');
    return Container(
      width: double.infinity,
      height: 162,
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

  _createNode() {
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
                    isDisable: true,
                  ),
                ),
                Expanded(
                  flex: 1,
//                  child: Center(
//                    child: InkWell(
//                      child: Text(
//                        S.of(context).atlas_launch_tutorial,
//                        style: TextStyle(
//                          color: DefaultColors.color999,
//                          fontSize: 12,
//                        ),
//                      ),
//                      onTap: () {
//                        AtlasApi.goToAtlasMap3HelpPage(context);
//                      },
//                    ),
//                  ),
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

  void _pushWalletManagerAction() {
    Application.router.navigateTo(
        context,
        Routes.map3node_create_wallet +
            "?pageType=${Map3NodeCreateWalletPage.CREATE_WALLET_PAGE_TYPE_JOIN}");
  }

  _myNodes() {
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
                S.of(context).my_atlas_nodes,
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
                      return _nodeInfoItem(index);
                    }),
              )
            : _emptyListHint(),
      ],
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

  _nodeInfoItem(int index) {
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
//                  Text('',
//                      style: TextStyle(
//                        fontSize: 10,
//                        color: HexColor("#9B9B9B"),
//                      )),
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

  _refreshData() async {
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
      setState(() {});
      _loadDataBloc.add(RefreshSuccessEvent());
    } catch (e) {
      _loadDataBloc.add(RefreshFailEvent());
    }

    if (mounted) setState(() {});
  }

  _loadMoreData() async {
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
    if (mounted) setState(() {});
  }
}
