import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:titan/src/business/infomation/api/news_api.dart';
import 'package:titan/src/business/infomation/model/news_detail.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InfoDetailPage extends StatefulWidget {
  final String url;
  final String title;
  final int id;

  InfoDetailPage({@required this.id, @required this.url, @required this.title});

  @override
  State<StatefulWidget> createState() {
    return _InfoDetailState();
  }
}

class _InfoDetailState extends State<InfoDetailPage> {
  NewsApi _newsApi = NewsApi();

  NewsDetail newsDetail = NewsDetail(0, 0, "", "", "", "", null);

  @override
  void initState() {
    if (widget.url.isEmpty) {
      _getInfoDetail();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoadingContent = false;
    if (widget.url.isEmpty) {
      isLoadingContent = true;
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: isLoadingContent ? _loadContent() : _loadUrl());
  }

  Widget _loadUrl() {
    return WebView(
      javascriptMode: JavascriptMode.unrestricted,
      initialUrl: widget.url,
    );
  }

  Widget _loadContent() {
    return SingleChildScrollView(
      child: Html(
        padding: EdgeInsets.symmetric(horizontal: 16,vertical: 16),
        data: newsDetail.content,
      ),
    );
  }

  Future _getInfoDetail() async {
    newsDetail = await _newsApi.getNewsDetai(widget.id);
    setState(() {});
  }
}
