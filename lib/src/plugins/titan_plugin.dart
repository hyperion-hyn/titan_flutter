import 'dart:async';

import 'package:flutter/services.dart';

class TitanPlugin {
  static final MethodChannel callChannel = MethodChannel('org.hyn.titan/call_channel');
  static final EventChannel eventChannel = EventChannel('org.hyn.titan/event_stream');

  static void initFlutterMethodCall() {
    callChannel.setMethodCallHandler(_platformCallHandler);
  }

  static Future<dynamic> _platformCallHandler(MethodCall call) async {
    switch (call.method) {
      case "dartGreet":
        String result = "";
        Map<dynamic, dynamic> params = call.arguments;
        params.forEach((k, v) {
          result += " k:$k, v:$v";
        });
        return result;
        break;
    }
  }

  static Future<String> greetNative() async {
    return await callChannel.invokeMethod("nativeGreet");
  }

  static StreamSubscription listenCipherEvent(onData, {Function onError, void onDone(), bool cancelOnError}) {
    return eventChannel.receiveBroadcastStream('cipherChangeEvent').listen(onData, onDone: onDone, onError: onError, cancelOnError: cancelOnError);
  }
}
