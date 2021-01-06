import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/pages/red_pocket/rp_record_detail_page.dart';
import 'package:titan/src/pages/red_pocket/rp_transmit_page.dart';


class RpTransmitTabPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RpTransmitTabState();
  }
}

class _RpTransmitTabState extends BaseState<RpTransmitTabPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: BaseAppBar(
          baseTitle: S.of(context).rp_transmit_pool,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          actions: <Widget>[
            IconButton(
              icon: Image.asset(
                "res/drawable/ic_tooltip.png",
                width: 16,
                height: 16,
              ),
              onPressed: () {
                //_showInfoAlertView();
              },
            ),
          ],
        ),
        body: Scaffold(
          appBar: new PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: new Container(
              width: double.infinity,
              height: 50.0,
              //color: HexColor('#F8F8F8'),
              //color: Colors.white,
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
                            '直接传导',
                          ),
                        ),
                        Tab(
                          child: Text(
                            'Map3传导',
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
              RpTransmitPage(type: RpTransmitType.DIRECT,),
              RpTransmitPage(type: RpTransmitType.MAP3,),
            ],
          ),
        ),
      ),
    );
  }
}

