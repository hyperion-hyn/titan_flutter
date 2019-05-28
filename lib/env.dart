import 'package:meta/meta.dart';

class BuildFlavor {
  static const String official = 'official';
  static const String google = 'google';
  static const String ios = 'ios';
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
