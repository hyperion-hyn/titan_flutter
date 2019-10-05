import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InfoDetailPage extends StatefulWidget {
  final String url;
  final String title;

  InfoDetailPage({@required this.url, @required this.title});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _InfoDetailState();
  }
}

class _InfoDetailState extends State<InfoDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: widget.url,
      ),
    );
  }
}
