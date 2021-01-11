import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/pages/red_pocket/rp_record_detail_page.dart';
import 'package:titan/src/pages/red_pocket/rp_record_list_page.dart';
import 'package:titan/src/pages/red_pocket/rp_record_statistics_page.dart';

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
          /*
          actions: <Widget>[
            FlatButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RpRecordStatisticsPage(),
                  ),
                );
              },
              child: Text(
                '每日统计',
                style: TextStyle(
                  color: HexColor("#1F81FF"),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
          */
        ),
        body: Scaffold(
          appBar: new PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: new Container(
              width: double.infinity,
              height: 50.0,
              //color: HexColor('#F8F8F8'),
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 10,
                    child: TabBar(
                      labelColor: HexColor('#FF001B'),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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
                            S.of(context).share,
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
              RpRecordListPage(rpType: RedPocketType.SHARE,),
            ],
          ),
        ),
      ),
    );
  }
}

