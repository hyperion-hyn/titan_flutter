import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:titan/env.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  BuildEnvironment.init(channel: BuildChannel.OFFICIAL, buildType: BuildType.DEV);

  ExchangeApi api = ExchangeApi();
  ExchangeHttp.instance.packageInfo = MockPackageInfo();

  test('update app api', () async {
    var p = 'moo';
    var data = await api.ping(p);
    expect(data, 'pong $p');
  });

//  test('test user api sign', () async {
//    api.getAccessSeed();
//  });
}

class MockPackageInfo {
  String version = '0.0.0';
  int buildNumber = 0;
}
