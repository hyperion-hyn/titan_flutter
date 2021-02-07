import 'main.dart' as Main;

import 'env.dart';

void main() {///packageType 为   正式版 “”   公测版 “ab”   内测版 “test”
  BuildEnvironment.init(channel: BuildChannel.OFFICIAL, buildType: BuildType.PROD, packageType: "");
  assert(env != null);
  Main.main();
}
