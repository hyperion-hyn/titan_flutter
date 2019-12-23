import 'package:flutter/services.dart';
import '../business/home/sensor/bloc.dart';

class SensorPlugin {
  final SensorBloc bloc;

  final MethodChannel callChannel =
      MethodChannel('org.hyn.titan/sensor_call_channel');

  SensorPlugin(this.bloc) {
    initFlutterMethodCall();
  }

  void initFlutterMethodCall() {
    callChannel.setMethodCallHandler(_platformCallHandler);
  }

  Future<dynamic> _platformCallHandler(MethodCall call) async {
    switch (call.method) {
      case "sensor#valueChange":
        Map<dynamic, dynamic> params = call.arguments;
        //print('params: $params');
        bloc.add(ValueChangeListenerEvent(params));

        return true;
    }
    return false;
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
