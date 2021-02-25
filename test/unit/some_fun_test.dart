
import 'package:characters/characters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:titan/env.dart';

void main() {
  BuildEnvironment.init(channel: BuildChannel.OFFICIAL, buildType: BuildType.DEV);

  test('some func test', () async {
    var result = await Future.wait([
      Future.delayed(Duration(seconds: 5), () => 1),
      Future.delayed(Duration(seconds: 1), () { throw 'some err'; }),
    ], eagerError: true);
    expect(result.length, 2);
    print(result);
  });

  test('some as test', () async {
    var mapEnt = Map();
    mapEnt["amount"] = 0;
    var stringEnt = '';
    // var doubleEnt = double.parse(mapEnt["amount"]);
    dynamic dynaEnt;
    String str2Ent = "string";
    dynaEnt = str2Ent;
    // print(doubleEnt);
    print(dynaEnt);
  });

  test('some trans test', () async {
    var mapEnt = Map();
    mapEnt["amount"] = 0;
    var amountFrom = amountFromJson(mapEnt);
    var amountTo = amountToJson(null);
    var testKey = mapEnt['aaa'];
    print("$amountFrom  $amountTo  $testKey");
  });
}

double amountFromJson(dynamic json) {
return double.parse(json['amount'].toString());
}

String amountToJson(dynamic amount) {
return amount.toString();
}
