import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';

class AtlasMyNodeListPage extends StatefulWidget {
  final NodeJoinType _nodeJoinType;

  AtlasMyNodeListPage(this._nodeJoinType);

  @override
  State<StatefulWidget> createState() {
    return AtlasMyNodeListPageState();
  }
}

class AtlasMyNodeListPageState extends State<AtlasMyNodeListPage>
    with AutomaticKeepAliveClientMixin {
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  AtlasApi _atlasApi = AtlasApi();

  List<AtlasInfoEntity> _atlasNodeList = List();

  int _currentPage = 1;
  int _pageSize = 30;

  @override
  void initState() {
    super.initState();
    _loadDataBloc.add(LoadingEvent());
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    _loadDataBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
        child: LoadDataContainer(
          bloc: _loadDataBloc,
          onLoadData: () {
            _refreshData();
          },
          onRefresh: () {
            _refreshData();
          },
          onLoadingMore: () {
            _loadMoreData();
          },
          child: _pageWidget(context),
        ),
      ),
    );
  }

  Widget _pageWidget(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return _nodeDetailItem(_atlasNodeList[index]);
            },
            childCount: _atlasNodeList.length,
          ),
        ),
      ],
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
                          child: Text(_atlasInfo.getNodeType,
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
    print('[atlas] _refreshData');
    try {
      var _nodeList = await _atlasApi.postAtlasNodeList(
        'address',
        page: _currentPage,
        size: _pageSize,
      );
      print('[atlas]: _nodeList: $_nodeList');
      _atlasNodeList.addAll(_nodeList);
      _loadDataBloc.add(RefreshSuccessEvent());
    } catch (e) {
      print('[atlas]: _nodeList: failed');
      _loadDataBloc.add(RefreshSuccessEvent());
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
      _currentPage++;

      ///
      _loadDataBloc.add(LoadingMoreSuccessEvent());
    } catch (e) {
      print('[atlas]: _nodeList: failed');
      _loadDataBloc.add(LoadingMoreSuccessEvent());
    }
    _loadDataBloc.add(LoadingMoreSuccessEvent());

    if (mounted) setState(() {});
  }
}
