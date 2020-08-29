import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_my_node_list_page.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/committee_info_entity.dart';
import 'package:titan/src/pages/webview/webview.dart';
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

  CommitteeInfoEntity _committeeInfo = CommitteeInfoEntity.fromJson({});

  List<AtlasInfoEntity> _atlasNodeList = List();
  List<AtlasInfoEntity> _myAtlasNodeList = List();

  ///load more for [_atlasNodeList]
  ///
  int _currentPage = 1;
  int _pageSize = 10;

  var _atlasNodeCoordinates = [];

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
    _getAtlasNodesCoordinates();
    _getCommitteeInfo();
  }

  _getCommitteeInfo() async {
    try {
      _committeeInfo = await _atlasApi.postAtlasOverviewData();
      print('[_getCommitteeInfo]: ${_committeeInfo.startTime}');
    } catch (e) {
      print('[_getCommitteeInfo]: $e');
    }
  }

  _getAtlasNodesCoordinates() {
    _atlasNodeCoordinates = [
      {
        "name": "Sydney",
        "value": [151.2002, -33.8591, 4, 4]
      },
      {
        "name": "Singapore",
        "value": [103.819836, 1.352083, 8, 8]
      },
      {
        "name": "Paris",
        "value": [2.35222, 48.8566, 10, 10]
      },
      {
        "name": "Jakarta",
        "value": [106.865, -6.17511, 1, 1]
      },
      {
        "name": "San Jose",
        "value": [-121.895, 37.3394, 2, 2]
      },
      {
        "name": "Ashburn",
        "value": [-77.4874, 39.0438, 114, 114]
      },
      {
        "name": "Mumbai",
        "value": [72.8777, 19.076, 6, 6]
      },
      {
        "name": "Seoul",
        "value": [126.978, 37.5665, 1, 1]
      },
      {
        "name": "Tokyo",
        "value": [139.692, 35.6895, 6, 6]
      },
      {
        "name": "Hong Kong",
        "value": [114.109, 22.3964, 9, 9]
      },
    ];
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
                      padding: EdgeInsets.all(16),
                      child: Text(
                        '节点列表',
                        style: TextStyle(
                          fontSize: 16,
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
        _atlasMap(),
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
                      '当前纪元',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      '${_committeeInfo.epoch}',
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
                      '区块高度',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    InkWell(
                      child: Text(
                        '#${_committeeInfo.blockNum}',
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
                      '当选节点',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      '${_committeeInfo.elected}',
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
                      '候选节点',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      '${_committeeInfo.candidate}',
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
    var _remainTime = 15;
    var _loopTime = 3600 * 24;

//    var date = DateTime.parse('2020-05-05T20:17:22Z');
//    var _ageStartTime =
//        DateTime.parse(_committeeInfo.startTime).millisecondsSinceEpoch;
//    var _ageEndTime =
//        DateTime.parse(_committeeInfo.endTime).millisecondsSinceEpoch;
//
//    var _remainTimeMilliseconds = _ageEndTime - _ageStartTime;

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
              AtlasMapWidget(_atlasNodeCoordinates),
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
                      '下个纪元',
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
                              angle:
                                  _ageIconAnimationController.value * 2 * 3.14,
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
                          loopTime: _loopTime,
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _createNode() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8),
      child: Container(
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: ClickOvalButton(
                '创建Atlas节点',
                () {
                  Application.router.navigateTo(
                    context,
                    Routes.atlas_create_node_page,
                  );
                },
                fontSize: 16,
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(left: 280.0),
                  child: InkWell(
                    child: Text(
                      '开通教程',
                      style: TextStyle(
                        color: DefaultColors.color999,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WebViewContainer(
                                    initUrl: '',
                                    title: 'Atlas Tutorial',
                                  )));
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
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
            vertical: 16.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                '我的节点',
                style: TextStyle(
                  fontSize: 16,
                ),
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
        _myAtlasNodeList.isNotEmpty
            ? Container(
                height: 150,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return _nodeInfoItem(index);
                    }),
              )
            : Container(
                height: 150,
                child: Center(
                  child: Text('暂无记录'),
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
          return _nodeDetailItem(_atlasNodeList[index]);
        },
        childCount: _atlasNodeList.length,
      ));
    } else {
      return SliverToBoxAdapter(
        child: Container(
          height: 200,
          color: Colors.red,
        ),
      );
    }
  }

  _nodeInfoItem(int index) {
    return InkWell(
      onTap: () {
        Application.router.navigateTo(context, Routes.atlas_detail_page);
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
                    blurRadius: 20.0,
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
                    child: Text("大道至简",
                        style: TextStyle(
                          fontSize: 12,
                          color: HexColor("#333333"),
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text('出块节点',
                      style: TextStyle(
                        fontSize: 10,
                        color: HexColor("#9B9B9B"),
                      )),
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

  _nodeDetailItem(AtlasInfoEntity _atlasInfo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () async {
          Application.router.navigateTo(context, Routes.atlas_detail_page);
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
                              text: _atlasInfo.name ?? 'name',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16)),
                          TextSpan(text: "", style: TextStyles.textC333S14bold),
                        ])),
                        Container(
                          height: 4,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              '节点排名: ',
                              style: TextStyles.textC9b9b9bS12,
                            ),
                            Text(
                              '${1}',
                              style: TextStyles.textC333S11,
                            ),
                          ],
                        )
                      ],
                    ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            _atlasInfo.createdAt,
                            style: TextStyle(
                                fontSize: 12, color: HexColor("#9B9B9B")),
                          ),
                        ),
                        Container(
                          height: 4,
                        ),
                        Container(
                          color: HexColor("#1FB9C7").withOpacity(0.08),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text("_atlasInfo.getNodeType",
                              style: TextStyle(
                                fontSize: 12,
                                color: HexColor("#5C4304"),
                              )),
                        ),
                      ],
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text.rich(TextSpan(children: [
                              TextSpan(
                                  text: '预期收益: ',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              TextSpan(text: ' '),
                              TextSpan(
                                  text: _atlasInfo.rewardRate,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ))
                            ])),
                          ),
                          Expanded(
                            child: Text.rich(TextSpan(children: [
                              TextSpan(
                                  text: '总抵押: ',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              TextSpan(text: ' '),
                              TextSpan(
                                  text: _atlasInfo.staking,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ))
                            ])),
                          )
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text.rich(TextSpan(children: [
                            TextSpan(
                                text: '管理费: ',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            TextSpan(text: ' '),
                            TextSpan(
                                text: _atlasInfo.feeRate,
                                style: TextStyle(
                                  fontSize: 12,
                                ))
                          ])),
                        ),
                        Expanded(
                          child: Text.rich(TextSpan(children: [
                            TextSpan(
                                text: '签名率: ',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            TextSpan(text: ' '),
                            TextSpan(
                                text: _atlasInfo.signRate,
                                style: TextStyle(
                                  fontSize: 12,
                                ))
                          ])),
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _refreshData() async {
    _currentPage = 1;
    _atlasNodeList.clear();
    try {
      var _nodeList = await _atlasApi.postAtlasNodeList(
        'address',
        page: _currentPage,
        size: _pageSize,
      );
      _atlasNodeList.addAll(_nodeList);

      ///
      _myAtlasNodeList.addAll(_nodeList);

      _loadDataBloc.add(RefreshSuccessEvent());
    } catch (e) {
      _loadDataBloc.add(RefreshFailEvent());
    }

    if (mounted) setState(() {});
  }

  _loadMoreData() async {
    try {
      var _nodeList = await _atlasApi.postAtlasNodeList(
        'address',
        page: _currentPage + 1,
        size: _pageSize,
      );

      _atlasNodeList.addAll(_nodeList);

      ///
      _myAtlasNodeList.addAll(_nodeList);

      ///
      _currentPage++;

      ///
      _loadDataBloc.add(LoadingMoreSuccessEvent());
    } catch (e) {
      _loadDataBloc.add(LoadMoreFailEvent());
    }
    _loadDataBloc.add(LoadingMoreSuccessEvent());
    if (mounted) setState(() {});
  }
}
