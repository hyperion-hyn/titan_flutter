
import 'package:flutter/services.dart';

typedef UMengTokenCallBack = void Function(String values);

class PushPlugin{

  final MethodChannel callChannel = MethodChannel('org.hyn.titan/push_call_channel');
  UMengTokenCallBack umengTokenCallBack;


  PushPlugin() {
    initFlutterMethodCall();
  }

  void initFlutterMethodCall() {
//    callChannel.setMethodCallHandler(_platformCallHandler);
  }

  /*Future<dynamic> _platformCallHandler(MethodCall call) async {
    switch (call.method) {
      case "push#umengToken":
        String params = call.arguments;

        if (umengTokenCallBack != null) {
          umengTokenCallBack(params);
        }

        return null;
    }
  }*/

  Future<String> getUMengToken() async {
    return await callChannel.invokeMethod('push#getUMengToken');
  }

}