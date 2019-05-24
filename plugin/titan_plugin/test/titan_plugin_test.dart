import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:titan_plugin/titan_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('titan_plugin');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await TitanPlugin.platformVersion, '42');
  });
}
