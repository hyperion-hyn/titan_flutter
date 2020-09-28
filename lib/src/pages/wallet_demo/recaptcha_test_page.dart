import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RecaptchaTestPage extends StatefulWidget {
  final String apiKey;
  final String language;
  final String pluginURL;
  final String verifyUrl;

  RecaptchaTestPage({
    this.language,
    this.apiKey,
    this.pluginURL = "https://www.hyn.space/titan/recaptcha.html",
    this.verifyUrl = "https://recaptcha.net/recaptcha/api/siteverify",
  });

  @override
  State<StatefulWidget> createState() {
    return _RecaptchaTestPageState();
  }
}

class _RecaptchaTestPageState extends State<RecaptchaTestPage> {
  WebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: WebView(
        initialUrl: "${widget.pluginURL}?api_key=${widget.apiKey}&hl=${widget.language ?? 'en'}",
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: <JavascriptChannel>[
          JavascriptChannel(
            name: 'RecaptchaFlutterChannel',
            onMessageReceived: (JavascriptMessage receiver) {
              // print(receiver.message);
              String _token = receiver.message;
              if (_token.contains("verify")) {
                _token = _token.substring(7);
              }

              Navigator.of(context).pop(_token);
            },
          ),
        ].toSet(),
        onWebViewCreated: (_controller) {
          webViewController = _controller;
        },
      ),
    );
  }

  @override
  void dispose() {
//    webViewController.clearCache();
    super.dispose();
  }
}
