import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/wallet/model/hyn_transfer_history.dart';
import 'map3_node_public_widget.dart';

class Map3NodeTxLogsPage extends StatefulWidget {
  final Map3InfoEntity map3infoEntity;
  final LoadDataBloc loadDataBloc;

  Map3NodeTxLogsPage(this.map3infoEntity, this.loadDataBloc);

  @override
  State<StatefulWidget> createState() {
    return Map3NodeTxLogsPageState();
  }
}

class Map3NodeTxLogsPageState extends State<Map3NodeTxLogsPage> {
  List<HynTransferHistory> _dataList = List();
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  Map3InfoEntity _map3infoEntity;
  String get _nodeAddress => _map3infoEntity?.address ?? '';

  int _currentPage = 1;
  final AtlasApi _atlasApi = AtlasApi();
  String get _nodeCreatorAddress => _map3infoEntity?.creator ?? '';

  @override
  void initState() {
    super.initState();

    _map3infoEntity = widget?.map3infoEntity;

    if (widget?.loadDataBloc != null) {
      widget.loadDataBloc.listen((state) {
        print("[$runtimeType] state:$state");

        if (state is RefreshSuccessState) {
          _refreshData();
        } else if (state is LoadMoreEmptyState) {
          _loadMoreData();
        }
      });
    } else {
      _refreshData();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _loadDataBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _dataList.length * 80.0,
      child: LoadDataContainer(
        bloc: _loadDataBloc,
        onLoadData: () async {
          await _refreshData();
        },
        onRefresh: () async {
          await _refreshData();
        },
        onLoadingMore: () {
          _loadMoreData();
          setState(() {});
        },
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            return delegateRecordItemWidget(
              _dataList[index],
              map3CreatorAddress: _nodeCreatorAddress,
            );
          },
          itemCount: _dataList.length,
        ),
      ),
    );
  }

  Future _refreshData() async {
    _currentPage = 1;
    _dataList.clear();

    var networkList = await _atlasApi.getMap3StakingLogList(
      _nodeAddress,
      page: _currentPage,
    );

    if (networkList != null) {
      _dataList.addAll(networkList);
    }

    _loadDataBloc.add(RefreshSuccessEvent());
    if (mounted) setState(() {});
  }

  _loadMoreData() async {
    _currentPage++;

    var networkList = await _atlasApi.getMap3StakingLogList(
      _nodeAddress,
      page: _currentPage,
    );

    if (networkList != null) {
      _dataList.addAll(networkList);
    }
    _loadDataBloc.add(LoadingMoreSuccessEvent());

    if (networkList.length > 0) {
      widget.loadDataBloc.add(LoadingMoreSuccessEvent());
    } else {
      widget.loadDataBloc.add(LoadMoreEmptyEvent());
    }

    if (mounted) setState(() {});
  }
}
