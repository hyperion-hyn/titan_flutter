import 'package:flutter/services.dart';

class SensorPlugin {
  SensorPlugin() {
    initFlutterMethodCall();
  }

  final MethodChannel callChannel = MethodChannel('org.hyn.titan/sensor_call_channel');

  void initFlutterMethodCall() {
    callChannel.setMethodCallHandler(_platformCallHandler);
  }

  Future<dynamic> _platformCallHandler(MethodCall call) async {
    switch (call.method) {
      case "sensor#valueChange":
        String result = "";
        Map<dynamic, dynamic> params = call.arguments;
        print(params);
        return null;
    }
  }

  Future<String> init() async {
    return await callChannel.invokeMethod('sensor#init');
  }

  Future<String> startScan() async {
    return await callChannel.invokeMethod('sensor#startScan');
  }

  Future<String> stopScan() async {
    return await callChannel.invokeMethod('sensor#stopScan');
  }

  Future<String> destory() async {
    return await callChannel.invokeMethod('sensor#destory');
  }
}
