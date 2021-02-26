import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/pages/wallet/dapp_authorization_dialog_page.dart';
import 'package:titan/src/pages/wallet/model/wallet_send_dialog_util.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

class WebViewBrowserContainer extends StatefulWidget {
  final String initUrl;
  final String title;

  WebViewBrowserContainer({this.initUrl, this.title = ''});

  @override
  State<StatefulWidget> createState() {
    return WebViewBrowserContainerState();
  }
}


class WebViewBrowserContainerState extends State<WebViewBrowserContainer> {
  WebViewController webViewController;

  String title;

  bool isLoading = true;

  Function onBackPress;
  Function onForwardPress;

  final _controller = Completer<WebViewController>();

  _loadHtmlFromAssets() async {
    // String fileHtmlContents = await rootBundle.loadString("res/web/js_bridge.html");
    String fileHtmlContents = await rootBundle.loadString("res/web/imtoken.html");
    _controller.future.then((v) => v?.loadUrl(Uri.dataFromString(fileHtmlContents,
        mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString()));
  }

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
        appBar: BaseAppBar(
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
              tooltip: S.of(context).share,
              onPressed: (){
                _shareQr(context);
              },
            ),
          ],
          baseTitle: title ?? widget.title,
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
      // initialUrl: '',
      onWebViewCreated: (WebViewController controller) {
        webViewController = controller;

        // _controller.complete(controller);

        // _loadHtmlFromAssets();

        // if (widget.initUrl?.isEmpty ?? true) _loadHtmlFromAssets();
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
      javascriptChannels: [NativeBridge(context, _controller.future)].toSet(),
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



class NativeBridge implements JavascriptChannel {
  BuildContext context;
  Future<WebViewController> _controller;

  NativeBridge(this.context, this._controller);

  Map<String, dynamic> _getValue(data) => {"value": 1};


  /*
  Map<String, dynamic> _getValue(data) => {"value": 1};

  Future<Map<String, dynamic>> _inputText(data) async {

    String text = await showDialog(
        context: context,
        builder: (_) {
          final textController = TextEditingController();
          return AlertDialog(
            content: TextField(controller: textController),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.pop(context, textController.text),
                  child: Icon(Icons.done)),
            ],
          );
        });

    return {"text": text ?? ""};
  }

  Map<String, dynamic> _showSnackBar(data) {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text(data["text"] ?? "")));
    return null;
  }

  Map<String, dynamic> _showSnackBarJs(data) {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text(data["text"] ?? "")));
    return null;
  }

  Map<String, dynamic> _newWebView(data){
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => WebViewContainer(initUrl: data["url"])));

    return null;
  }
  */

  Future<bool> showSendDialog<T>() {
    DAppAuthorizationDialogEntity entity = DAppAuthorizationDialogEntity(
      title: '访问说明',
      dAppName: 'RP 红包',
    );

    return showDAppAuthorizationDialog(
      context: context,
      entity: entity,
    );
  }

  get _functions => <String, Function>{
    // "getValue": _getValue,
    // "getAuthorAddress": _getAuthorAddress,
    // "inputText": _inputText,
    // "showSnackBar": _showSnackBar,
    // "showSnackBarJs": _showSnackBarJs,
    // "newWebView": _newWebView,
    "device.getCurrentCurrency": _getCurrentCurrency,
  };


  Map<String, dynamic> _getCurrentCurrency(data) => {"value": 1};


  Future<Map<String, dynamic>> _getAuthorAddress(data) async {

    var isOK = await showSendDialog();
    String text = isOK ? '【${WalletModelUtil.walletName}】address: ${WalletModelUtil.walletHynShortAddress}':'No';

    return {"text": text ?? ""};
  }

  @override
  // String get name => "nativeBridge";
  String get name => "imToken";



  @override
  get onMessageReceived => (msg) async {
    print("[xxx] msg:$msg");

    Map<String, dynamic> message = json.decode(msg.message);
    final data = await _functions[message["api"]](message["data"]);
    message["data"] = data;
    _controller.then((v) => v.evaluateJavascript(
        "window.jsBridge.receiveMessage(${json.encode(message)})"));
  };
}
