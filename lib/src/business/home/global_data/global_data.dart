
import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/home/global_data/echarts/signal_chart.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GlobalDataPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GlobalDataState();
  }
}


class _GlobalDataState extends State<GlobalDataPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
              _webPage(
                initUrl: 'https://news.hyn.space/react-reduction/',
              ),
              SignalChatsPage(),
              SignalChatsPage(),
            ],
            physics: NeverScrollableScrollPhysics(),
          ),
        ),
      ),
    );
  }


  Widget _webPage({String initUrl}) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text('Map3节点是支持整个海伯利安地图网络的基本，XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX介绍一番'),
        ),
        Expanded(
          child: WebView(
            initialUrl: initUrl,
            onWebViewCreated: (WebViewController controller) {

            },
            onPageFinished: (String url) async {

            },
            javascriptMode: JavascriptMode.unrestricted,
            navigationDelegate: (NavigationRequest request) {
              bool prevent = false;

              //非http/https协议
              if (!request.url.startsWith(RegExp('^https?://'))) {
                prevent = true;
              }
              var strs = request.url.split('/');
              var route = strs[strs.length - 1];

              //下载apk
              if (route.contains('.apk')) {
                prevent = true;
              }

              if (prevent) {
                return NavigationDecision.prevent;
              }

              return NavigationDecision.navigate;
            },
          ),
        ),
      ],
    );
  }
}