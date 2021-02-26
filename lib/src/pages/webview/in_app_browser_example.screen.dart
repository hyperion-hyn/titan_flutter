import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyInAppBrowser extends InAppBrowser {
  @override
  Future onBrowserCreated() async {
    print("\n\nBrowser Created!\n\n");


  }

  @override
  Future onLoadStart(url) async {
    print("\n\nStarted $url\n\n");
  }

  @override
  Future onLoadStop(url) async {
    print("\n\nStopped $url\n\n");

    var source = """ 
      window.addEventListener("flutterInAppWebViewPlatformReady", function(event) { 
                window.flutter_inappwebview.callHandler('handlerFoo') 
                  .then(function(result) { 
                    // print to the console the data coming 
                    // from the Flutter side. 
                    console.log(JSON.stringify(result)); 
                     
                    window.flutter_inappwebview 
                      .callHandler('handlerFooWithArgs', 1, true, ['bar', 5], {foo: 'baz'}, result); 
                }); 
            }); 
    """;
    webViewController.evaluateJavascript(source: source);
  }

  @override
  void onLoadError(url, code, message) {
    print("Can't load $url.. Error: $message");
  }

  @override
  void onProgressChanged(progress) {
    print("Progress: $progress");
  }

  @override
  void onExit() {
    print("\n\nBrowser closed!\n\n");
  }

  @override
  void onLoadResource(response) {
    print("Started at: " +
        response.startTime.toString() +
        "ms ---> duration: " +
        response.duration.toString() +
        "ms " +
        (response.url ?? '').toString());
  }

  @override
  void onConsoleMessage(consoleMessage) {

    print("""
    console output:
      message: ${consoleMessage.message}
      messageLevel: ${consoleMessage.messageLevel.toValue()}
   """);
  }
}



inAppBrowserOpenUrl({String url}) async {
  var browser = MyInAppBrowser();

  browser.webViewController.addJavaScriptHandler(
      handlerName: 'handlerFoo',
      callback: (args) {
        // return data to JavaScript side!
        return {'bar': 'bar_value', 'baz': 'baz_value'};
      });

  browser.webViewController.addJavaScriptHandler(
      handlerName: 'handlerFooWithArgs',
      callback: (args) {
        print(args);
        // it will print: [1, true, [bar, 5], {foo: baz}, {bar: bar_value, baz: baz_value}]
      });

  await browser.openUrl(
    url: url,
    options: InAppBrowserClassOptions(
      inAppWebViewGroupOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          useOnLoadResource: true,
          debuggingEnabled: true,
        ),
      ),
    ),
  );
}

/*
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}
class _MyAppState extends State<MyApp> {
  InAppWebViewController _webViewController;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('InAppWebView Example'),
        ),
        body: Container(
            child: Column(children: <Widget>[
              Expanded(
                child:InAppWebView(
                  initialData: InAppWebViewInitialData(
                      data: """
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    </head>
    <body>
        <h1>JavaScript Handlers (Channels) TEST</h1>
        <script>
            window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
                window.flutter_inappwebview.callHandler('handlerFoo')
                  .then(function(result) {
                    // print to the console the data coming
                    // from the Flutter side.
                    console.log(JSON.stringify(result));

                    window.flutter_inappwebview
                      .callHandler('handlerFooWithArgs', 1, true, ['bar', 5], {foo: 'baz'}, result);
                });
            });
        </script>
    </body>
</html>
                      """
                  ),
                  initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        debuggingEnabled: true,
                      )
                  ),
                  onWebViewCreated: (InAppWebViewController controller) {
                    _webViewController = controller;
                    _webViewController.addJavaScriptHandler(handlerName:'handlerFoo', callback: (args) {
                      // return data to JavaScript side!
                      return {
                        'bar': 'bar_value', 'baz': 'baz_value'
                      };
                    });
                    _webViewController.addJavaScriptHandler(handlerName: 'handlerFooWithArgs', callback: (args) {
                      print(args);
                      // it will print: [1, true, [bar, 5], {foo: baz}, {bar: bar_value, baz: baz_value}]
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    print(consoleMessage);
                    // it will print: {message: {"bar":"bar_value","baz":"baz_value"}, messageLevel: 1}
                  },
                ),
              ),
            ])),
      ),
    );
  }
}
*/
