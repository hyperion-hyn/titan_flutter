import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:titan/env.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/wallet/api/bitcoin_api.dart';

void main() {

  setUp((){
    TestWidgetsFlutterBinding.ensureInitialized();
    BuildEnvironment.init(channel: BuildChannel.OFFICIAL, buildType: BuildType.DEV);
  });

  testWidgets('widget test', (WidgetTester tester) async {
    // You can use keys to locate the widget you need to test
    var sliderKey = new GlobalKey(debugLabel: '__root_page__');
    var btcResponse;

    // Tells the tester to build a UI based on the widget tree passed to it
    await tester.pumpWidget(
      new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return new MaterialApp(
            home: new Material(
                child: WalletComponent(
                  child: new InkWell(
                    key: Keys.rootKey,
                    onTap: () async {
                      btcResponse = await BitcoinApi.requestBtcFeeRecommend();
                      print("");
                    },
                    child: Text("hahaha", key: sliderKey),
                  ),
                ),
            ),
          );
        },
      ),
    );

    // Taps on the widget found by key
    await tester.tap(find.byKey(sliderKey));

    print(btcResponse.toString());
    // Verifies that the widget updated the value correctly
//    expect(btcResponse != null, true);
  });
}