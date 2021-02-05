import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:titan/src/pages/red_pocket/rp_record_list_page.dart';
import 'package:titan/src/pages/red_pocket/rp_share_record_tab_page.dart';


class RpRecordTabPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RpRecordTabState();
  }
}

class _RpRecordTabState extends BaseState<RpRecordTabPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: BaseAppBar(
          baseTitle: S.of(context).my_redpocket,
          backgroundColor: Colors.white,
        ),
        body: Scaffold(
          appBar: new PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: new Container(
              width: double.infinity,
              height: 40.0,
              //color: HexColor('#F8F8F8'),
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TabBar(
                      labelColor: HexColor('#FF001B'),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: HexColor('#FF001B'),
                      indicatorWeight: 2,
                      indicatorPadding: EdgeInsets.only(
                        bottom: 2,
                        right: 12,
                        left: 12,
                      ),
                      unselectedLabelColor: HexColor("#FF333333"),
                      tabs: [

                        Tab(
                          child: Text(
                            S.of(context).lucky_rp,
                          ),
                        ),
                        Tab(
                          child: Text(
                            S.of(context).level_rp,
                          ),
                        ),
                        Tab(
                          child: Text(
                            S.of(context).promotion_rp,
                          ),
                        ),
                        Tab(
                          child: Text(
                            S.of(context).share_rp,
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
              RpRecordListPage(rpType: RedPocketType.LUCKY,),
              RpRecordListPage(rpType: RedPocketType.LEVEL,),
              RpRecordListPage(rpType: RedPocketType.PROMOTION,),
              RpShareRecordTabPage(),
            ],
          ),
        ),
      ),
    );
  }
}

