
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
}
