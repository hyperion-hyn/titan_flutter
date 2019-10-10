import 'main.dart' as Main;

import 'env.dart';

void main() {
  BuildEnvironment.init(channel: BuildChannel.STORE, buildType: BuildType.PROD);
  assert(env != null);
  Main.main();
}
