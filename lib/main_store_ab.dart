import 'main.dart' as Main;

import 'env.dart';

void main() {
  BuildEnvironment.init(channel: BuildChannel.STORE, buildType: BuildType.PROD, packageType: "ab");
  assert(env != null);
  Main.main();
}
