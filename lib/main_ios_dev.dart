import 'main.dart' as Main;

import 'env.dart';

void main() {
  BuildEnvironment.init(flavor: BuildFlavor.ios, buildType: BuildType.dev);
  assert(env != null);
  Main.main();
}
