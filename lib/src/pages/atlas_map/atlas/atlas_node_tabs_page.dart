import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/atlas/atlas_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/app_tabbar/bloc/bloc.dart';
import 'package:titan/src/pages/atlas_map/event/node_event.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_nodes_page.dart';
import 'package:titan/src/pages/skeleton/skeleton_node_tabs_page.dart';
import 'package:titan/src/style/titan_sytle.dart';

class AtlasNodeTabsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AtlasNodeTabsPageState();
  }
}

class _AtlasNodeTabsPageState extends State<AtlasNodeTabsPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  StreamSubscription _eventBusSubscription;

  LoadDataBloc _loadDataBloc = LoadDataBloc();

  @override
  void initState() {
    _tabController = new TabController(initialIndex: 0, vsync: this, length: 2);
    super.initState();
    _listenEventBus();
    _loadDataBloc.add(LoadingEvent());
  }

  _listenEventBus() {
    _eventBusSubscription = Application.eventBus.on().listen((event) async {
      if (event is UpdateMap3TabsPageIndexEvent) {
        this.setState(() {
          _tabController.index = event.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _loadDataBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppTabBarBloc, AppTabBarState>(
      listener: (context, state) {
        if (state is ChangeNodeTabBarItemState) {
          this.setState(() {
            _tabController.index = state.index;
          });
        }
      },
      child: Scaffold(
        body: LoadDataContainer(
          bloc: _loadDataBloc,
          onRefresh: () {},
          onLoadData: () {},
          onLoadingMore: () {},
          onLoadSkeletonView: SkeletonNodeTabsPage(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  height: 100,
                  color: Colors.amberAccent,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _epochInfo() {
    return Container(
      width: double.infinity,
      child: Stack(
        children: [],
      ),
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
      child: AtlasNodesPage(
        loadDataBloc: _loadDataBloc,
      ),
    );
  }

  _pageView() {
    return Container(
      height: 100,
      width: 100,
      child: PageView(
        children: [
          Container(
            color: Colors.amber,
          ),
          Container(
            color: Colors.red,
          )
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
}
