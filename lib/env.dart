import 'package:meta/meta.dart';

enum BuildChannel { OFFICIAL, STORE }

enum BuildType { DEV, PROD }

BuildEnvironment get env => _env;
BuildEnvironment _env;
//toto
bool get showLog => env.buildType == BuildType.DEV;
// bool get showLog => true;

class BuildEnvironment {
  final BuildType buildType;
  final BuildChannel channel;

  BuildEnvironment._init({this.channel, this.buildType});

  /// Sets up the top-level [env] getter on the first call only.
  static void init({@required channel, @required buildType}) =>
      _env ??= BuildEnvironment._init(channel: channel, buildType: buildType);
}
