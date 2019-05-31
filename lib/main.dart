import 'package:flutter/material.dart';
import 'package:titan/src/app.dart';

import 'env.dart';
import 'src/plugins/titan_plugin.dart';

void main() {
  if (env == null) {
    BuildEnvironment.init(flavor: BuildFlavor.official, buildType: BuildType.dev);
  }

  TitanPlugin.initFlutterMethodCall();

  runApp(App());
}
