import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/app_tabbar/bloc/bloc.dart';
import 'package:titan/src/pages/atlas_map/event/node_event.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_nodes_page.dart';
import 'package:titan/src/pages/atlas_map/widget/atlas_info_widget.dart';
import 'package:titan/src/widget/clip_tab_bar.dart';

enum NodeTab { map3, atlas }

class AtlasNodeTabsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AtlasNodeTabsPageState();
  }
}

class _AtlasNodeTabsPageState extends State<AtlasNodeTabsPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  PageController _pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );
  ScrollController _scrollController = ScrollController();

  NodeTab _selectedNodeTab = NodeTab.map3;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _listenEventBus();
  }

  _listenEventBus() {
    Application.eventBus.on().listen((event) async {
      if (event is UpdateMap3TabsPageIndexEvent) {
        _selectedNodeTab = event.index == 0 ? NodeTab.map3 : NodeTab.atlas;
        if (_pageController.hasClients) {
          _pageController.jumpToPage(event.index);
        }
        if (mounted) setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppTabBarBloc, AppTabBarState>(
      listener: (context, state) {
        if (state is ChangeNodeTabBarItemState) {
          _selectedNodeTab = state.index == 0 ? NodeTab.map3 : NodeTab.atlas;
          if (_pageController.hasClients) {
            _pageController.jumpToPage(state.index);
          }
          if (mounted) setState(() {});
        }
      },
      child: Scaffold(
        body: Container(
          color: Colors.white,
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
                child: AtlasInfoWidget(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      height: 135,
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          _tabBar(),
                          Column(
                            children: [
                              Container(
                                height: 50,
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(
                                    16.0,
                                  )),
                                  child: Container(
                                    color: Colors.white,
                                    padding: EdgeInsets.only(top: 4),
                                    width: double.infinity,
                                    child: PageView(
                                      controller: _pageController,
                                      physics: NeverScrollableScrollPhysics(),
                                      children: [
                                        Map3NodePage(
                                          scrollController: _scrollController,
                                        ),
                                        AtlasNodesPage(
                                          scrollController: _scrollController,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
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

  _nodeTab({
    @required bool selected,
    @required String logoPath,
    @required String name,
  }) {
    return Wrap(
      children: [
        Image.asset(
          logoPath,
          width: 20.0,
          height: 20.0,
          color: selected ? Theme.of(context).primaryColor : Colors.white,
        ),
        SizedBox(
          width: 8.0,
        ),
        Text(
          name,
          style: TextStyle(
            color: selected ? Theme.of(context).primaryColor : Colors.white,
            fontSize: 18.0,
          ),
        )
      ],
    );
  }

  _tabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: ClipTabBar(
        selectedNodeTab: _selectedNodeTab,
        children: [
          _nodeTab(
            selected: _selectedNodeTab == NodeTab.map3,
            logoPath: 'res/drawable/ic_map3_logo.png',
            name: 'Map3',
          ),
          _nodeTab(
            selected: _selectedNodeTab == NodeTab.atlas,
            logoPath: 'res/drawable/ic_atlas_logo.png',
            name: 'Atlas',
          ),
        ],
        onTabChanged: (nodeTab) {
          setState(() {
            _selectedNodeTab = nodeTab;
          });
          _pageController.jumpToPage(
            _selectedNodeTab == NodeTab.map3 ? 0 : 1,
          );
        },
        onTabDoubleTap: (nodeTab) {
          setState(() {
            _selectedNodeTab = nodeTab;
          });
          _pageController.jumpToPage(
            _selectedNodeTab == NodeTab.map3 ? 0 : 1,
          );
          _scrollController.animateTo(0.0,
              duration: Duration(
                milliseconds: 300,
              ),
              curve: Curves.decelerate);
        },
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
    );
  }
}
