 import 'package:flutter/services.dart';

typedef SensorChangeCallBack = void Function(Map values);

class SensorPlugin {
  SensorPlugin() {
    initFlutterMethodCall();
  }

  SensorChangeCallBack sensorChangeCallBack;

  final MethodChannel callChannel = MethodChannel('org.hyn.titan/sensor_call_channel');

  void initFlutterMethodCall() {
    callChannel.setMethodCallHandler(_platformCallHandler);
  }

  Future<dynamic> _platformCallHandler(MethodCall call) async {
    switch (call.method) {
      case "sensor#valueChange":
        Map<dynamic, dynamic> params = call.arguments;
        if (sensorChangeCallBack != null) {
          sensorChangeCallBack(params);
        }
        print('[sensor_plugin] --> param:${params}');

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
