import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/pages/red_pocket/rp_share_get_list_page.dart';
import 'package:titan/src/pages/red_pocket/rp_share_send_list_page.dart';

class RpShareRecordTabPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RpShareRecordTabState();
  }
}

class _RpShareRecordTabState extends BaseState<RpShareRecordTabPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: new PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: new Container(
            width: double.infinity,
            height: 50.0,
            color: HexColor('#F8F8F8'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Container(),
                ),
                Expanded(
                  flex: 4,
                  child: TabBar(
                    labelColor: HexColor('#FF001B'),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorColor: HexColor('#F8F8F8'),
                    indicatorWeight: 0.05,
                    indicatorPadding: EdgeInsets.only(
                      bottom: 2,
                      right: 12,
                      left: 12,
                    ),
                    unselectedLabelColor: HexColor("#FF333333"),
                    tabs: [
                      Tab(
                        child: Text(
                          '我收到的',
                        ),
                      ),
                      Tab(
                        child: Text(
                          '我发出的',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            RpShareGetListPage(),
            RpShareSendListPage(),
          ],
        ),
      ),
    );
  }
}
