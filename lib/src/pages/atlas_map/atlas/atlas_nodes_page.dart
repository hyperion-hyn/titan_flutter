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
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_my_node_list_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_node_detail_item.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_home_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/committee_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/atlas_map_widget.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/timer_text.dart';

import 'atlas_my_node_page.dart';

class AtlasNodesPage extends StatefulWidget {
  AtlasNodesPage();

  @override
  State<StatefulWidget> createState() {
    return AtlasNodesPageState();
  }
}

class AtlasNodesPageState extends State<AtlasNodesPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  LoadDataBloc _loadDataBloc = LoadDataBloc();

  ///
  AtlasApi _atlasApi = AtlasApi();

  AnimationController _ageIconAnimationController;

  List<AtlasInfoEntity> _atlasNodeList = List();

  AtlasHomeEntity _atlasHomeEntity;

  ///load more for [_atlasNodeList]
  ///
  int _currentPage = 1;
  int _pageSize = 10;

  bool _isAutoRefresh = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadDataBloc.add(LoadingEvent());
    _ageIconAnimationController = new AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    super.dispose();
    _loadDataBloc.close();
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
      _isAutoRefresh = true;
      setState(() {});
    } catch (e) {
      _isAutoRefresh = false;
      setState(() {});
      print('[_getCommitteeInfo]: $e');
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
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: _atlasInfo(),
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
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      S.of(context).atlas_current_age,
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      '${_atlasHomeEntity?.info?.epoch}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      S.of(context).block_height,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    InkWell(
                      child: Text(
                        '#${_atlasHomeEntity?.info?.blockNum}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      S.of(context).atlas_elected_nodes,
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      '${_atlasHomeEntity?.info?.elected}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      S.of(context).atlas_candidate_nodes,
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      '${_atlasHomeEntity?.info?.candidate}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  _atlasMap() {
    var _secPerBlock = _atlasHomeEntity?.info?.secPerBlock ?? 0;
    var _blocksPerEpoch = _atlasHomeEntity?.info?.blockHeight ?? 0;
    var _currentBlockNum = _atlasHomeEntity?.info?.blockNum ?? 0;
    var _epochStartBlockNum = _atlasHomeEntity?.info?.blockNumStart ?? 0;

    ///total time of 1 epoch:  blocksPerEpoch * secPerBlock
    ///
    var _secPerEpoch = _blocksPerEpoch * _secPerBlock;

    ///remain time: remainBlockCount * secPerBlock
    ///remainBlockCount = blocksPerEpoch - (currentBlockNum - startBlockNum)
    ///
    var _remainTime = _secPerBlock *
        (_blocksPerEpoch - (_currentBlockNum - _epochStartBlockNum));

    var points = json.decode(_atlasHomeEntity?.points ?? '{}');

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
                    'Atlas共识节点',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    '为海伯利安生态提供共识保证',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  )
                ],
              ),
            ),
            Positioned(
              right: 16,
              top: 8,
              child: Column(
                children: <Widget>[
                  Text(
                    S.of(context).atlas_next_age,
                    style:
                        TextStyle(color: HexColor('#FFFFFFFF'), fontSize: 10),
                  ),
                  SizedBox(height: 4),
                  Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      AnimatedBuilder(
                        animation: _ageIconAnimationController,
                        builder: (_, child) {
                          return Transform.rotate(
                            angle: _ageIconAnimationController.value * 2 * 3.14,
                            child: child,
                          );
                        },
                        child: Image.asset(
                          'res/drawable/ic_atlas_age.png',
                          width: 60,
                          height: 60,
                        ),
                      ),
                      TimerTextWidget(
                        remainTime: _remainTime,
                        loopTime: _secPerEpoch,
                        isLoopFunc: _isAutoRefresh,
                        loopFunc: () {
                          _getData();
                        },
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _createNode() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 0),
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
                  child: Center(
                    child: InkWell(
                      child: Text(
                        S.of(context).atlas_launch_tutorial,
                        style: TextStyle(
                          color: DefaultColors.color999,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () {
                        AtlasApi.goToAtlasMap3HelpPage(context);
                      },
                    ),
                  ),
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
                '我的节点',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  Application.router.navigateTo(
                    context,
                    Routes.atlas_my_node_page,
                  );
                },
                child: Text(
                  '查看更多',
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
            : Center(
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
                    Text('暂无记录'),
                  ],
                ),
              ),
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
        child: Container(
          height: 200,
          child: Center(
            child: Text(S.of(context).exchange_empty_list),
          ),
        ),
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
                  Image.asset(
                    "res/drawable/map3_node_default_avatar.png",
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                  ),
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
        _atlasNodeList.addAll(_nodeList);
      }

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

      if (_nodeList != null) {
        _atlasNodeList.addAll(_nodeList);
        _currentPage++;
      }

      _loadDataBloc.add(LoadingMoreSuccessEvent());
    } catch (e) {
      _loadDataBloc.add(LoadMoreFailEvent());
    }
    _loadDataBloc.add(LoadingMoreSuccessEvent());
    if (mounted) setState(() {});
  }
}
