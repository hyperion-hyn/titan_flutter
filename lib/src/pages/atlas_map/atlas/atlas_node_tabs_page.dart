import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/atlas/atlas_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/memory_cache.dart';
import 'package:titan/src/pages/app_tabbar/bloc/bloc.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_home_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_home_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_introduce_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_staking_entity.dart';
import 'package:titan/src/pages/atlas_map/event/node_event.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_create_wallet_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_detail_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_list_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_nodes_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/atlas_map/widget/atlas_info_widget.dart';
import 'package:titan/src/pages/atlas_map/widget/my_map3_node_info_item_v2.dart';
import 'package:titan/src/pages/atlas_map/widget/node_active_contract_widget.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/pages/node/model/node_head_entity.dart';
import 'package:titan/src/pages/skeleton/skeleton_map3_node_page.dart';
import 'package:titan/src/pages/skeleton/skeleton_node_tabs_content.dart';
import 'package:titan/src/pages/skeleton/skeleton_node_tabs_page.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/atlas_map_widget.dart';
import 'package:titan/src/widget/clip_tab_bar.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/map3_nodes_widget.dart';

import 'atlas_node_detail_item.dart';

enum NodeTab { map3, atlas }

class AtlasNodeTabsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AtlasNodeTabsPageState();
  }
}

class _AtlasNodeTabsPageState extends State<AtlasNodeTabsPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  PageController _pageController;
  StreamSubscription _eventBusSubscription;

  NodeTab _selectedNodeTab = NodeTab.map3;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _pageController = PageController(
      initialPage: 0,
      keepPage: true,
    );
    super.initState();
    _listenEventBus();
  }

  _listenEventBus() {
    _eventBusSubscription = Application.eventBus.on().listen((event) async {
      if (event is UpdateMap3TabsPageIndexEvent) {
        this.setState(() {
          _pageController.jumpToPage(event.index);
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
            _pageController.jumpToPage(state.index);
          });
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
                                height: 49.5,
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
                                        Map3NodePage(),
                                        AtlasNodesPage(),
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
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: ClipTabBar(
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
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 50,
          child: Row(
            children: [
              Expanded(
                child: Container(
                    color: _selectedNodeTab == NodeTab.map3
                        ? Colors.white
                        : Colors.black.withOpacity(0.5)),
              ),
              Expanded(
                child: Container(
                  color: _selectedNodeTab == NodeTab.atlas
                      ? Colors.white
                      : Colors.black.withOpacity(0.5),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  _skeletonMap() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(
          16.0,
        )),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[100],
          enabled: true,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
              width: double.infinity,
              height: 162,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
