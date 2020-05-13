import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/pages/news/news_page.dart';
import 'package:titan/src/pages/news/wechat_official_page.dart';

class InformationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _InformationPageState();
  }
}

class _InformationPageState extends State<InformationPage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            child: Material(
              elevation: 3,
              child: SafeArea(
                child: Row(
                  children: <Widget>[
                    Spacer(
                      flex: 1,
                    ),
                    Expanded(
                      flex: 3,
                      child: TabBar(
                        labelColor: Colors.black,
                        labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorColor: Theme.of(context).primaryColor,
                        indicatorWeight: 5,
                        unselectedLabelColor: Colors.grey[400],
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
                    Spacer(
                      flex: 1,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            NewsPage(),
            WechatOfficialPage(),
          ],
          physics: PageScrollPhysics(),
        ),
      ),
    );
  }
}
