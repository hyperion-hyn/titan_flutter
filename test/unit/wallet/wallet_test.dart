
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:titan/env.dart';
import 'package:titan/src/pages/wallet/api/bitcoin_api.dart';

void main(){

  setUp((){
//    WidgetsFlutterBinding.ensureInitialized();
    BuildEnvironment.init(channel: BuildChannel.OFFICIAL, buildType: BuildType.DEV);
  });

  test('test btc fee', () async {
    var btcResponse = await BitcoinApi.requestBtcFeeRecommend();

    expect(btcResponse != null, true);
  });

}