import 'package:meta/meta.dart';

class BuildFlavor {
  static const String androidOfficial = 'android_official';
  static const String androidGoogle = 'android_google';
  static const String iosStore = 'ios_store';
  static const String iosEnterprise = 'ios_enterprise';
}

class BuildType {
  static const String dev = 'dev';
  static const String prod = 'prod';
}

BuildEnvironment get env => _env;
BuildEnvironment _env;

class BuildEnvironment {
  final String buildType;
  final String flavor;

  BuildEnvironment._init({this.flavor, this.buildType});

  /// Sets up the top-level [env] getter on the first call only.
  static void init({@required flavor, @required buildType}) => _env ??= BuildEnvironment._init(flavor: flavor, buildType: buildType);
}
