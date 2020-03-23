import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/home/global_data/echarts/signal_chart.dart';

class GlobalDataPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GlobalDataState();
  }
}

class _GlobalDataState extends State<GlobalDataPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          //S.of(context).map3_global_nodes,
          "全球数据",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              child: Material(
                elevation: 3,
                child: SafeArea(
                  child: Row(
                    children: <Widget>[
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
                              text: 'Map3节点',
                            ),
                            Tab(
                              text: '信号数据',
                            ),
                            Tab(
                              text: 'POI数据',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              SignalChatsPage(type: SignalChatsPage.NODE),
              SignalChatsPage(type: SignalChatsPage.SIGNAL),
              SignalChatsPage(type: SignalChatsPage.POI),
            ],
            physics: NeverScrollableScrollPhysics(),
          ),
        ),
      ),
    );
  }
}
