import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_reward_list_page.dart';
import 'package:titan/src/routes/routes.dart';

class Map3NodeRewardTabsPage extends StatefulWidget {
  Map3NodeRewardTabsPage();

  @override
  State<StatefulWidget> createState() {
    return _Map3NodeRewardTabsPageState();
  }
}

class _Map3NodeRewardTabsPageState extends State<Map3NodeRewardTabsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).my_reward,
        actions: [
          FlatButton(
            onPressed: () {
              Application.router.navigateTo(
                context,
                Routes.map3node_my_page_reward,
              );
            },
            child: Text(
              S.of(context).extract_records,
              style: TextStyle(
                color: HexColor("#1F81FF"),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
      body: Map3NodeRewardListPage(),
    );
  }
}
