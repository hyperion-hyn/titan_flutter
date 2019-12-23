import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/src/business/home/sensor/bloc.dart';

typedef SensorChangeCallBack = void Function(Map values);

class SensorPlugin {
  SensorPlugin(this._bloc) {
    initFlutterMethodCall();
  }

  SensorBloc _bloc;
  //SensorChangeCallBack sensorChangeCallBack;

  final MethodChannel callChannel = MethodChannel('org.hyn.titan/sensor_call_channel');

  void initFlutterMethodCall() {
    callChannel.setMethodCallHandler(_platformCallHandler);
  }

  Future<dynamic> _platformCallHandler(MethodCall call) async {
    switch (call.method) {
      case "sensor#valueChange":
        String result = "";
        Map<dynamic, dynamic> params = call.arguments;

        _bloc.add(ValueChangeListenerEvent(params));
//        if (sensorChangeCallBack != null) {
//          sensorChangeCallBack(params);
//        }
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
