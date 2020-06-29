import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

typedef MessagePushCallBack = void Function(Map values);
typedef UrlLauncherCallBack = void Function(Map values);

class TitanPlugin {
  static final MethodChannel callChannel =
      MethodChannel('org.hyn.titan/call_channel');
  static final EventChannel keyPairChangeChannel =
      EventChannel('org.hyn.titan/event_stream');
  static MessagePushCallBack msgPushChangeCallBack;
  static UrlLauncherCallBack urlLauncherCallBack;

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

      case "printLog":
        String result = call.arguments;
        String platform = Platform.operatingSystem.toUpperCase();
        print("[${platform}] :${result}");

        // todo: test
        /*var text = "<!-- wp:image {\"id\":1346,\"align\":\"center\"} -->\n<div class=\"wp-block-image\"><figure class=\"aligncenter\"><img src=\"https:\/\/news.hyn.space\/wp-content\/uploads\/2020\/02\/signal-attachment-2020-02-24-231552-650x1024.jpeg\" alt=\"\" class=\"wp-image-1346\"\/><\/figure><\/div>\n<!-- \/wp:image -->";
        Map values = {
          "title": "新增“宅经济体验合约",
          "text": text,
          "out_link": "",
        };
        msgPushChangeCallBack(values);
       */
        break;

      case "msgPush":
        Map result = call.arguments;
        msgPushChangeCallBack(result);
        break;

      case "urlLauncher":
        /*
        Map values = {
          "type": "contract",
          "subType": "detail",
          "content": {
              "contractId": 8,
          },
        };
        */
        Map result = call.arguments;
        urlLauncherCallBack(result);
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

  static Future<bool> getClipboardData() async {
    print("main onMethodCall111");
    return await callChannel.invokeMethod('clipboardData');
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

  static Future<String> encrypt(String pubKey, String message) async {
    return await callChannel
        .invokeMethod("encrypt", {'publicKey': pubKey, 'message': message});
  }

  static Future<Map> activeEncrypt(String message, String password, String fileName) async {
    return await callChannel
        .invokeMethod("activeEncrypt", {'message': message, 'password': password, 'fileName': fileName});
  }

  static Future<String> decrypt(String cipherText, String password, String fileName) async {
    return await callChannel.invokeMethod("decrypt", {'cipherText': cipherText, 'password': password, 'fileName': fileName});
  }

  static StreamSubscription listenCipherEvent(onData,
      {Function onError, void onDone(), bool cancelOnError}) {
    return keyPairChangeChannel
        .receiveBroadcastStream('keypair_change_event')
        .listen(onData,
            onDone: onDone, onError: onError, cancelOnError: cancelOnError);
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
    return callChannel
        .invokeMethod("shareImage", {'path': path, 'title': title});
  }

  static Future<dynamic> shareText(String text, String title) {
    return callChannel
        .invokeMethod("shareText", {'text': text, 'title': title});
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

  /// only android
  static Future<dynamic> installApk(String path) async {
    return await callChannel.invokeMethod('installApk', {'path': path});
  }

  static Future<dynamic> openMarket({String packageName}) async {
    return await callChannel
        .invokeMethod('openMarket', {'packageName': packageName});
  }

  static Future<String> fileMd5(String path) async {
    return await callChannel.invokeMethod('fileMd5', {'path': path});
  }

  static Future<bool> wifiEnable() async {
    return await callChannel.invokeMethod('wifiEnable');
  }

  static Future<bool> bluetoothEnable() async {
    return await callChannel.invokeMethod('bluetoothEnable');
  }

  static Future<String> signBitcoinRawTx(String transJson) async {
    return await callChannel
        .invokeMethod("bitcoinSign", {'transJson': transJson});
  }
}
