import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/app_tabbar/bloc/bloc.dart';
import 'package:titan/src/pages/atlas_map/event/node_event.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_nodes_page.dart';

class Map3NodeTabsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Map3NodeTabsPageState();
  }
}

class _Map3NodeTabsPageState extends State<Map3NodeTabsPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  StreamSubscription _eventBusSubscription;

  @override
  void initState() {
    _tabController = new TabController(initialIndex: 0, vsync: this, length: 2);
    super.initState();
    _listenEventBus();
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            color: Theme.of(context).primaryColor,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      labelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      indicatorPadding: EdgeInsets.only(bottom: 2),
                      unselectedLabelColor: HexColor("#aaffffff"),
                      tabs: [
                        Tab(
                          text: S.of(context).map3_node_introduction,
                        ),
                        Tab(
                          text: "Atlas",
                        ),
                      ],
                    ),
                  ),
                  Expanded(flex: 2, child: Text(""))
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            Map3NodePage(),
            AtlasNodesPage(),
          ],
        ),
      ),
    );
  }
}
