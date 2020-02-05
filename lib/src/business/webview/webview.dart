import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

class WebViewContainer extends StatefulWidget {
  final String initUrl;
  final String title;

  WebViewContainer({this.initUrl, this.title = ''});

  @override
  State<StatefulWidget> createState() {
    return WebViewContainerState();
  }
}


class WebViewContainerState extends State<WebViewContainer> {
  WebViewController webViewController;

  String title;

  bool isLoading = true;

  Function onBackPress;
  Function onForwardPress;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (webViewController != null) {
          if (await webViewController.canGoBack()) {
            webViewController.goBack();
            return false;
          }
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              );
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              color: Colors.white,
              tooltip: S.of(context).share,
              onPressed: (){
                _shareQr(context);
              },
            ),
          ],
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          title: Text(
            title ?? widget.title,
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              if (isLoading)
                SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(
//                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  ),
                ),
              Expanded(
                child: _body(),
              ),
              Visibility(
                visible: onBackPress != null || onForwardPress != null,
                child: Column(
                  children: <Widget>[
                    Divider(
                      height: 0,
                    ),
                    Container(
                      height: 48,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            onPressed: onBackPress,
                            icon: Icon(Icons.chevron_left),
                            disabledColor: Colors.grey[200],
                          ),
                          SizedBox(
                            width: 40,
                          ),
                          IconButton(
                            onPressed: onForwardPress,
                            icon: Icon(Icons.chevron_right),
                            disabledColor: Colors.grey[200],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {

    return WebView(
      initialUrl: widget.initUrl,
      onWebViewCreated: (WebViewController controller) {
        webViewController = controller;
      },
      onPageFinished: (String url) async {
        String _title = await webViewController?.getTitle();
        if (_title?.isNotEmpty == true) {
          setState(() {
            title = _title;
          });
        }
        setState(() {
          isLoading = false;
        });

        updateBackOrForward();

        print('page loaded $title $url}');
      },
      javascriptMode: JavascriptMode.unrestricted,
      navigationDelegate: (NavigationRequest request) {
        bool prevent = false;

//                    if(request.url.contains('verify.meituan.com')) {
//                      prevent = true;
//                    }

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
          print(('block ${request.url}'));
          return NavigationDecision.prevent;
        }

        setState(() {
          isLoading = true;
        });

        print('allow ${request.url}');
        return NavigationDecision.navigate;
      },
    );
  }

  void updateBackOrForward() async {
    if (await webViewController?.canGoBack() == true) {
      onBackPress = () {
        webViewController.goBack();
      };
    } else {
      onBackPress = null;
    }

    if (await webViewController?.canGoForward() == true) {
      onForwardPress = () {
        webViewController.goForward();
      };
    } else {
      onForwardPress = null;
    }
    setState(() {});
  }

  void _shareQr(BuildContext context) async {
    if (widget.initUrl != null && widget.initUrl.isNotEmpty) {
      Share.text(S.of(context).share, widget.initUrl, 'text/plain');
    }
  }

}
