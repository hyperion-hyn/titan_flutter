import 'main.dart' as Main;

import 'env.dart';

void main() {
  BuildEnvironment.init(channel: BuildChannel.OFFICIAL, buildType: BuildType.DEV, packageType: "test");
  assert(env != null);
  Main.main();
}
