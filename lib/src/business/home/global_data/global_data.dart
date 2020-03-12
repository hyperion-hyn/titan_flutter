import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    //SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  }

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
              _webPage(),
              _signalPage(),
              _poiPage(),
            ],
            //physics: NeverScrollableScrollPhysics(),
          ),
        ),
      ),
    );
  }


  double _htmlHeight = 430;
  WebViewController _controller;
  Widget _webPage() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text('Map3节点是支持整个海伯利安地图网络的基本，XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX介绍一番'),
          ),
          Container(
            height: _htmlHeight,
            child: WebView(
              initialUrl: 'https://news.hyn.space/react-reduction/',
              onWebViewCreated: (WebViewController controller) {
                _controller = controller;
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
      ),
    );
  }

  /*void _setJSHandler(WebViewController controller) {
    JavaScriptHandlerCallback callback = (List<dynamic> arguments) async {
      // 解析argument, 获取到高度, 直接设置即可(iphone手机需要+20高度)
      double height = HtmlUtils.getHeight(arguments);
      if (height > 0) {
        setState(() {
          _htmlHeight = height;
        });
      }
    };
    controller.addJavaScriptHandler(HANDLER_NAME, callback);
  }*/

  Widget _signalPage() {
    var title = '信号数据可用于建立三角定位，XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX介绍一番';
    return SignalChatsPage(title);
  }

  Widget _poiPage() {
    var title = 'POI数据是一个公共的位置兴趣点数据集合，XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX介绍一番';
    return SignalChatsPage(title);
  }

}