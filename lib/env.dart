import 'package:meta/meta.dart';

enum BuildFlavor { official, google, ios }
enum BuildType { dev, prod }

BuildEnvironment get env => _env;
BuildEnvironment _env;

class BuildEnvironment {
  /// The backend server.
  final BuildType buildType;
  final BuildFlavor flavor;

  BuildEnvironment._init({this.flavor, this.buildType});

  /// Sets up the top-level [env] getter on the first call only.
  static void init({@required flavor, @required buildType}) => _env ??= BuildEnvironment._init(flavor: flavor, buildType: buildType);
}
