import 'dart:async';

import 'package:flutter/services.dart';

class TitanPlugin {
  static const MethodChannel _channel =
      const MethodChannel('titan_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
