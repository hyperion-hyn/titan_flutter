import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class StaticWebViewPage extends StatelessWidget {
  final String url;
  final String title;

  StaticWebViewPage(this.url, this.title);

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: url,
      appBar: new AppBar(
        title: new Text(title),
      ),
    );
  }
}
