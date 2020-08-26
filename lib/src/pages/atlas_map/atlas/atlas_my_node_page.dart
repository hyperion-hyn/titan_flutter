import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_my_node_list_page.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';

class AtlasMyNodePage extends StatefulWidget {
  AtlasMyNodePage();

  @override
  State<StatefulWidget> createState() {
    return _AtlasMyNodePageState();
  }
}

class _AtlasMyNodePageState extends State<AtlasMyNodePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(
      initialIndex: 0,
      vsync: this,
      length: 2,
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: BaseAppBar(baseTitle: '我的节点'),
        body: Scaffold(
          appBar: new PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: new Container(
              width: double.infinity,
              height: 50.0,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 10,
                    child: TabBar(
                      labelColor: HexColor('#FF333333'),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: HexColor('#FF333333'),
                      indicatorWeight: 3,
                      indicatorPadding: EdgeInsets.only(
                        bottom: 2,
                        right: 12,
                        left: 12,
                      ),
                      unselectedLabelColor: HexColor("#FF999999"),
                      tabs: [
                        Tab(
                          child: Text(
                            '我发起的',
                          ),
                        ),
                        Tab(
                          child: Text(
                            '我参与的',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(),
                  )
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              AtlasMyNodeListPage(NodeJoinType.CREATOR),
              AtlasMyNodeListPage(NodeJoinType.JOINER),
            ],
          ),
        ),
      ),
    );
  }
}
