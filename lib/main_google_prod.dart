import 'main.dart' as Main;

import 'env.dart';

void main() {
  BuildEnvironment.init(flavor: BuildFlavor.google, buildType: BuildType.prod);
  assert(env != null);
  Main.main();
}
