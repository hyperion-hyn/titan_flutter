import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

///see https://github.com/fluttercommunity/flutter_webview_plugin
class _WebViewPageState extends State<WebViewPage> {
  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: "https://www.baidu.com",
      appBar: new AppBar(
        title: new Text("Widget webview"),
      ),
    );
  }
}
