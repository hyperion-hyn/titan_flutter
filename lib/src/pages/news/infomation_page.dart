import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/news/news_page.dart';
import 'package:titan/src/pages/news/wechat_official_page.dart';

class InformationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _InformationPageState();
  }
}

class _InformationPageState extends State<InformationPage> {


  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            width: double.infinity,
            //height: 50.0,
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: <Widget>[
                  SizedBox(width: 16,),
                  Expanded(
                    flex: 10,
                    child: TabBar(
                      isScrollable: true,
                      labelColor: HexColor('#FF228BA1'),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: HexColor('#FF228BA1'),
                      indicatorWeight: 2,
                      indicatorPadding: EdgeInsets.only(
                        bottom: 2,
                        right: 12,
                        left: 12,
                      ),
                      unselectedLabelColor: HexColor("#FF333333"),
                      tabs: [
                        Tab(
                          text: S.of(context).Hyperion,
                        ),
                        Tab(
                          text: S.of(context).kais_talk,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16,),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            NewsPage(),
            WeChatOfficialPage(),
          ],
        ),
      ),
    );
  }
}
