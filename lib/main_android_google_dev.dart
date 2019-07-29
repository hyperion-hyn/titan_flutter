import 'main.dart' as Main;

import 'env.dart';

void main() {
  BuildEnvironment.init(flavor: BuildFlavor.androidGoogle, buildType: BuildType.dev);
  assert(env != null);
  Main.main();
}
