import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:titan/src/widget/widget_shot.dart';

class InAppWebViewContainer extends StatefulWidget {
  final String initUrl;
  final String title;

  InAppWebViewContainer({this.initUrl, this.title = ''});

  @override
  State<StatefulWidget> createState() {
    return InAppWebViewContainerState();
  }
}

class InAppWebViewContainerState extends State<InAppWebViewContainer> {
  final ShotController _shotController = new ShotController();

  InAppWebViewController webView;
  String url = "";
  double progress = 0;

  String title;
  bool isLoading = true;

  Function onBackPress;
  Function onForwardPress;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('[webview]  -->11111');
        if (webView != null) {
          print('[webview]  -->3333');

          if (await webView.canGoBack()) {
            print('[webview]  -->4444');

            webView.goBack();
            return false;
          }
        }
        print('[webview]  -->2222');

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
              onPressed: () {
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
                SizedBox(height: 2, child: progress < 1.0 ? LinearProgressIndicator(value: progress) : Container()),
              Expanded(
                child: _body(),
              ),
              if (onBackPress != null && onForwardPress != null)
                Column(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    print('[inapp] --> webView, url:${widget.initUrl}');

    return InAppWebView(
      initialUrl: widget.initUrl,
      initialHeaders: {},
      initialOptions: InAppWebViewWidgetOptions(
//        inAppWebViewOptions: InAppWebViewOptions(
//        debuggingEnabled: true,)
          ),
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;
      },
      onLoadStart: (InAppWebViewController controller, String url) {
        print("onLoadStart $url");
        setState(() {
          this.url = url;
        });
      },
      onLoadStop: (InAppWebViewController controller, String url) async {
        isLoading = false;
        print("onLoadStop $url");
        setState(() {
          this.url = url;
        });

        updateBackOrForward();
      },
      onProgressChanged: (InAppWebViewController controller, int progress) {
        print("onProgressChanged $url");

        setState(() {
          this.progress = progress / 100;
          print('[inapp] --> webView, progress:${progress}');
        });
      },
    );
  }

  void updateBackOrForward() async {
    if (await webView?.canGoBack() == true) {
      onBackPress = () {
        webView.goBack();
      };
    } else {
      onBackPress = null;
    }

    if (await webView?.canGoForward() == true) {
      onForwardPress = () {
        webView.goForward();
      };
    } else {
      onForwardPress = null;
    }

    setState(() {});
  }

  void _shareQr(BuildContext context) async {
    if (webView != null && !isLoading) {
      webView.takeScreenshot().then((imageByte) async {
        var len = imageByte.lengthInBytes;
        debugPrint("screenshot taken bytes $len");

        await Share.file(S.of(context).nav_share_app, 'app.png', imageByte, 'image/png');
      });
    }
  }
}
