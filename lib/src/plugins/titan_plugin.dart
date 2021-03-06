import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';


typedef MessagePushCallBack = void Function(Map values);
typedef UrlLauncherCallBack = void Function(Map values);

class TitanPlugin {
  static final MethodChannel callChannel =
      MethodChannel('org.hyn.titan/call_channel');
  static final EventChannel keyPairChangeChannel =
      EventChannel('org.hyn.titan/event_stream');
  static MessagePushCallBack msgPushChangeCallBack;
  static UrlLauncherCallBack urlLauncherCallBack;
  static String publicKey;
  static String privateKey;

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
        print("[$platform] :$result");

        break;

      case "msgPush":
        Map result = call.arguments;
        msgPushChangeCallBack(result);
        break;

      case "p2fDeeplink":
        Map result = call.arguments;
        urlLauncherCallBack(result);
        break;
    }
  }

  static Future<void> f2pDeeplink() async {
    await callChannel.invokeMethod('f2pDeeplink');
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

  static Future<String> getClipboardData() async {
    return await callChannel.invokeMethod('clipboardData');
  }

  static Future<String> genKeyPair({int expired = 0}) async {
    if (expired == 0) {
      expired = DateTime.now().millisecondsSinceEpoch + 3600 * 24 * 1000;
    }
    return await callChannel.invokeMethod('genKeyPair', expired);
  }

  static Future<String> getPublicKey() async {
    if (publicKey == null) {
      publicKey = await AppCache.secureGetValue(SecurePrefsKey.MY_PUBLIC_KEY);
      if (publicKey == null) {
        var pairMap = await callChannel.invokeMethod('genKeyPair');
        var privateKey = pairMap["privateKey"];
        publicKey = pairMap["publicKey"];
        await AppCache.secureSaveValue(
            SecurePrefsKey.MY_PRIVATE_KEY, privateKey);
        await AppCache.secureSaveValue(SecurePrefsKey.MY_PUBLIC_KEY, publicKey);
      }
    }
    return publicKey;
  }

  static Future<int> getExpiredTime() async {
    return await callChannel.invokeMethod("getExpired");
  }

  static Future<String> encrypt(String pubKey, String message) async {
    return await callChannel
        .invokeMethod("encrypt", {'pub': pubKey, 'message': message});
  }

  static Future<String> decrypt(String cipherText) async {
    if (privateKey == null) {
      privateKey = await AppCache.secureGetValue(SecurePrefsKey.MY_PRIVATE_KEY);
    }
    if (privateKey == null) {
      Fluttertoast.showToast(msg: S.of(Keys.rootKey.currentContext).key_pair_error_share_location_again);
      return "";
    }
    return await callChannel.invokeMethod(
        "decrypt", {'privateKey': privateKey, 'cipherText': cipherText});
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

  static Future<String> bitcoinActive(String fileName, String password) async {
    return await callChannel.invokeMethod(
        "bitcoinActive", {"fileName": fileName, "password": password});
  }

  static Future<void> jumpToBioAuthSetting() async {
    await callChannel.invokeMethod('jumpToBioAuthSetting');
  }

  static Future<String> trustActiveEncrypt(String password, String fileName) async {
    return await callChannel
        .invokeMethod("trustActiveEncrypt", {'password': password, 'fileName': fileName});
  }

  static Future<String> trustEncrypt(String pubKey, String message) async {
    return await callChannel
        .invokeMethod("trustEncrypt", {'publicKey': pubKey, 'message': message});
  }

  static Future<String> trustDecrypt(String cipherText, String password, String fileName) async {
    return await callChannel.invokeMethod("trustDecrypt", {'cipherText': cipherText, 'password': password, 'fileName': fileName});
  }
}
