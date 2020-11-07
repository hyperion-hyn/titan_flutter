import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/atlas/atlas_component.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_page.dart';

import 'atlas_nodes_page.dart';

class AtlasNodeTabPage extends StatefulWidget {
  AtlasNodeTabPage();

  @override
  State<StatefulWidget> createState() {
    return AtlasNodeTabPageState();
  }
}

class AtlasNodeTabPageState extends State<AtlasNodeTabPage> {
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
      appBar: AppBar(),
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
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Container(height: 60, child: Text("header")),
              ),
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
                      child: _atlasInfo(),
                    ),
                    Positioned(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: _nodePageView(),
                      ),
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }

  _nodePageView() {
    return Container(
      padding: EdgeInsets.only(
        top: 150,
        left: 16.0,
        right: 16.0,
      ),
      width: 500,
      height: 700,
      child: PageView(
        children: [
          Map3NodePage(),
          AtlasNodesPage(),
        ],
      ),
    );
  }

  _atlasInfo() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                '${S.of(context).atlas_next_age}: ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  shadows: [
                    BoxShadow(
                      offset: const Offset(1.0, 1.0),
                      blurRadius: 2.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                '${AtlasInheritedModel.of(context).remainBlockTillNextEpoch}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
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
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      S.of(context).atlas_current_age,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      '${AtlasInheritedModel.of(context).committeeInfo?.epoch}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    InkWell(
                      child: Text(
                        '${AtlasInheritedModel.of(context).committeeInfo?.blockNum}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          //color: Colors.blue,
                          //decoration: TextDecoration.underline,
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      '${AtlasInheritedModel.of(context).committeeInfo?.elected}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      '${AtlasInheritedModel.of(context).committeeInfo?.candidate}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  Future _refreshData() async {
    _currentPage = 1;
    _dataList.clear();

    var networkList;
    await Future.delayed(Duration(milliseconds: 1000), () {
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
    await Future.delayed(Duration(milliseconds: 1000), () {
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
