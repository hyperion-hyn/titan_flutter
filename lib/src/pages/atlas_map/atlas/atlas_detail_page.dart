import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';

class AtlasDetailPage extends StatefulWidget {
  AtlasDetailPage();

  @override
  State<StatefulWidget> createState() {
    return AtlasDetailPageState();
  }
}

class AtlasDetailPageState extends State<AtlasDetailPage> {
  List<String> _dataList = List();
  LoadDataBloc _loadDataBloc = LoadDataBloc();

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
      appBar: BaseAppBar(baseTitle: "节点详情"),
      body: LoadDataContainer(
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
          child:CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Container(
                    height: 60,
                    child: Text("header")),
              ),
              SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Container(
                        height: 60,
                        child: Text(_dataList[index]),
                    );
                  }, childCount: _dataList.length)
              )
            ],
          )
      ),
    );
  }

  Future _refreshData() async {
    _currentPage = 1;
    _dataList.clear();

    var networkList;
    await Future.delayed(Duration(milliseconds: 1000),(){
      networkList = List.generate(10, (index) {
        return index.toString();
      });
    });

    if (networkList != null) {
      _dataList.addAll(networkList);
    }

    _loadDataBloc.add(RefreshSuccessEvent());
    if (mounted) setState(() {});
  }

  _loadMoreData() async {
    _currentPage++;

    var networkList;
    await Future.delayed(Duration(milliseconds: 1000),(){
      networkList = List.generate(10, (index) {
        return index.toString();
      });
    });

    if (networkList != null) {
      _dataList.addAll(networkList);
    }
    _loadDataBloc.add(LoadingMoreSuccessEvent());
    if (mounted) setState(() {});
  }

}