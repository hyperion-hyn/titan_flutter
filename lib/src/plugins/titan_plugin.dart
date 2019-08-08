import 'dart:async';

import 'package:flutter/services.dart';

class TitanPlugin {
  static final MethodChannel callChannel = MethodChannel('org.hyn.titan/call_channel');
  static final EventChannel keyPairChangeChannel = EventChannel('org.hyn.titan/event_stream');

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

  //---------------------
  // encryption
  //---------------------
  static Future<String> initKeyPair({int expired = 0}) async {
    if (expired == 0) {
      expired = DateTime.now().millisecondsSinceEpoch + 3600 * 24 * 1000;
    }
    return await callChannel.invokeMethod('initKeyPair', expired);
  }

  static Future<String> genKeyPair({int expired = 0}) async {
    if (expired == 0) {
      expired = DateTime.now().millisecondsSinceEpoch + 3600 * 24 * 1000;
    }
    return await callChannel.invokeMethod('genKeyPair', expired);
  }

  static Future<String> getPublicKey() async {
    return await callChannel.invokeMethod('getPublicKey');
  }

  static Future<int> getExpiredTime() async {
    return await callChannel.invokeMethod("getExpired");
  }

  static StreamSubscription listenCipherEvent(onData, {Function onError, void onDone(), bool cancelOnError}) {
    return keyPairChangeChannel
        .receiveBroadcastStream('keypair_change_event')
        .listen(onData, onDone: onDone, onError: onError, cancelOnError: cancelOnError);
  }

  //---------------------
  // qrcode scan
  //---------------------
  static Future<String> scan() async {
    return await callChannel.invokeMethod("scan");
  }

  //---------------------
  // share
  //---------------------
  static Future<dynamic> shareImage(String path, String title) {
    return callChannel.invokeMethod("shareImage", {'path': path, 'title': title});
  }

  static Future<dynamic> shareText(String text, String title) {
    return callChannel.invokeMethod("shareText", {'text': text, 'title': title});
  }

  //---------------------
  // permission
  //---------------------

  /// only android
  static Future<bool> canRequestPackageInstalls() async {
    return await callChannel.invokeMethod("canRequestPackageInstalls");
  }

  /// only android
  static Future<bool> requestInstallUnknownSourceSetting() async {
    return await callChannel.invokeMethod("requestInstallUnknownSourceSetting");
  }
}
