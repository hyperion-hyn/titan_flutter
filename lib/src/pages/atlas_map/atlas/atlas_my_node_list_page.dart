import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_node_detail_item.dart';
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
              return AtlasNodeDetailItem(_atlasNodeList[index]);
            },
            childCount: _atlasNodeList.length,
          ),
        ),
      ],
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
