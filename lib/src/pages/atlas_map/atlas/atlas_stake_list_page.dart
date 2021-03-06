import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_stake_select_page.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as all_page_state;

class AtlasStakeListPage extends StatefulWidget {

  final AtlasInfoEntity _atlasInfoEntity;
  AtlasStakeListPage(this._atlasInfoEntity);

  @override
  State<StatefulWidget> createState() {
    return AtlasStakeListPageState();
  }
}

class AtlasStakeListPageState extends State<AtlasStakeListPage> {
  List<Map3InfoEntity> _dataList = List();
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  all_page_state.AllPageState _currentState = all_page_state.LoadingState();
  AtlasApi _atlasApi = AtlasApi();

  int _currentPage = 1;
  int _pageSize = 30;

  @override
  void initState() {
    super.initState();

    _loadDataBloc.add(LoadingEvent());
  }

  @override
  void dispose() {
    super.dispose();
    _loadDataBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          S.of(context).staking_atlas_node,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
      body: LoadDataContainer(
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
          child: _pageWidget(context)),
    );
  }

  Widget _pageWidget(BuildContext context) {
    if(widget._atlasInfoEntity == null){
      return Container();
    }
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 18.0, bottom: 20),
                child: stakeHeaderInfo(context,widget._atlasInfoEntity),
              ),
              Container(
                height: 10,
                color: HexColor("#F2F2F2"),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 14, right: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      S.of(context).join_delegate,
                      style: TextStyles.textC333S16,
                    ),
                    Spacer(),
                    Text(
                      S.of(context).nodes_in_total(_dataList.length),
                      style: TextStyles.textC999S12,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              Map3InfoEntity map3InfoEntity =_dataList[index];
              return Column(
                children: <Widget>[
                  SizedBox(height: 17,),
                  Padding(
                    padding: const EdgeInsets.only(left: 26.0, right: 26),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ClipOval(
                              child: Image.network(map3InfoEntity.home,
                                  fit: BoxFit.cover, width: 44, height: 44)),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(map3InfoEntity.name,style: TextStyles.textC000S14),
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0, bottom: 2),
                                child: Text(map3InfoEntity.address,style: TextStyles.textC999S12),
                              ),
                              Text(S.of(context).annualized_yesterday_reward_rate(map3InfoEntity.rewardRate),style: TextStyles.textC333S12),
                            ],
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Text("${map3InfoEntity.staking}",style: TextStyles.textC333S14),
                            SizedBox(height: 13,),
                            ClickOvalButton(
                              S.of(context).map3_node_delegate,
                                  () {},
                              width: 52,
                              height: 22,
                              fontSize: 12,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 14,),
                  Divider(color: DefaultColors.colorf2f2f2,indent: 26,endIndent: 26,)
                ],
              );
            }, childCount: _dataList.length))
      ],
    );
  }

  _refreshData() async {
    _currentPage = 1;
    _dataList.clear();

    _dataList = await _atlasApi.postAtlasMap3NodeList(widget._atlasInfoEntity.nodeId,page: _currentPage);
    _dataList.forEach((element) {
      element.name = "haha";
      element.address = "121112121";
      element.rewardRate = "11%";
      element.staking = "2313123";
      element.home = "http://www.missyuan.net/uploads/allimg/190815/14342Q051-0.png";
    });
    /*var networkList;
    await Future.delayed(Duration(milliseconds: 1000), () {
      networkList = List.generate(10, (index) {
        return index.toString();
      });
    });

    if (networkList != null) {
      _dataList.addAll(networkList);
    }*/

    _loadDataBloc.add(RefreshSuccessEvent());
    if (mounted) setState(() {});
  }

  _loadMoreData() async {
    _currentPage++;

    var _netDataList = await _atlasApi.postAtlasMap3NodeList(widget._atlasInfoEntity.nodeId,page: _currentPage);

    if (_netDataList != null) {
      _dataList.addAll(_netDataList);
      _loadDataBloc.add(LoadingMoreSuccessEvent());
    }else{
      _loadDataBloc.add(LoadMoreEmptyEvent());
    }
    if (mounted) setState(() {});
  }
}
