import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          title ?? widget.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: <Widget>[
          if (isLoading)
            SizedBox(
              height: 2,
              child: LinearProgressIndicator(
//                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
            ),
          Expanded(
            child: WebView(
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
                print('page loaded $title $url}');
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
      ),
    );
  }
}
