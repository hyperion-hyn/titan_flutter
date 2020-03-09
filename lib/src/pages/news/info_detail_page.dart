import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/infomation/api/news_api.dart';
import 'package:titan/src/business/infomation/model/news_detail.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InfoDetailPage extends StatefulWidget {
  final String url;
  final String title;
  final int id;
  final String userAgent;
  final String content;

  InfoDetailPage({
    this.id,
    @required this.url,
    @required this.title,
    this.userAgent,
    this.content,
  });

  @override
  State<StatefulWidget> createState() {
    return _InfoDetailState();
  }
}

class _InfoDetailState extends State<InfoDetailPage> {
  NewsApi _newsApi = NewsApi();

  NewsDetail newsDetail = NewsDetail(0, 0, "", "", "", "", null);
  bool isLoading = true;

  WebViewController webViewController;

  @override
  void initState() {
    super.initState();
    if (widget.url.isEmpty) {
      _getInfoDetail();
    }

    print('[info_detail] --> url:${widget.url}, userAgent:${widget.userAgent}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoadingContent = false;
    if (widget.url.isEmpty) {
      isLoadingContent = true;
    }

    return Scaffold(
        appBar: AppBar(
//          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.white),
          ),
          actions: isLoadingContent?null:<Widget>[
            IconButton(
              icon: Icon(Icons.share),
              color: Colors.white,
              tooltip: S.of(context).share,
              onPressed: (){
                _shareQr(context);
              },
            ),
          ]
        ),
        body: isLoadingContent ? _loadContent() : _loadUrl());
  }

  Widget _loadUrl() {
    return Column(
      children: <Widget>[
        if (isLoading)
          SizedBox(
            height: 2,
            child: LinearProgressIndicator(),
          ),
        Expanded(
          child: WebView(
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: widget.url,
            userAgent: widget.userAgent,
            onWebViewCreated: (WebViewController controller) {
              webViewController = controller;
            },
            onPageFinished: (String url) async {
              setState(() {
                isLoading = false;
              });
            },
            navigationDelegate: (NavigationRequest request) {
              bool prevent = false;

              //非http/https协议
              if (!request.url.startsWith(RegExp('^https?://'))) {
                prevent = true;
              }
              var strs = request.url.split('/');
              var route = strs[strs.length - 1];
              //下载apk
              if (route.startsWith('.apk')) {
                prevent = true;
              }
              if (prevent) {
                print(('block ${request.url}'));
                return NavigationDecision.prevent;
              }

              setState(() {
                isLoading = true;
              });

              print('allow ${request.url}');
              return NavigationDecision.navigate;
            },
          ),
        ),
      ],
    );
  }

  Widget _loadContent() {
    return SingleChildScrollView(
      child: Html(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        data: newsDetail.content,
      ),
    );
  }

  Future _getInfoDetail() async {
    if (widget.id == 0) {
      newsDetail.title = widget.title;
      newsDetail.content = widget.content;
    } else {
      newsDetail = await _newsApi.getNewsDetai(widget.id);
    }
    setState(() {});
  }

  void _shareQr(BuildContext context) async {
    if (widget.url != null && widget.url.isNotEmpty) {
      Share.text(S.of(context).share, widget.url, 'text/plain');
    }
  }
  
}
