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
  final GlobalKey _toolTipKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var message = '''
HYN传导RP是用户进入红包网络的通道，不同RP持有量和燃烧量可助用户满足晋升门槛，获得更多被空投红包砸中的机会。根据变化的Y值，可计算当下某个量级对应要求的最小RP持有量和累计燃烧量，以及需要抵押传导的HYN数额。
    ''';
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
                final dynamic tooltip = _toolTipKey.currentState;
                tooltip?.ensureTooltipVisible();
                //print("tooltip: $tooltip");
              },
              tooltip: message,
            ),
            Tooltip(
              key: _toolTipKey,
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16.0),
              message: message,
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
              RpTransmitPage(
                type: RpTransmitType.DIRECT,
              ),
              RpTransmitPage(
                type: RpTransmitType.MAP3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
