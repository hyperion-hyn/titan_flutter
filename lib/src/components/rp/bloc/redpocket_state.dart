import 'package:meta/meta.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_my_level_info.dart';

@immutable
abstract class RedPocketState {}

class InitialAtlasState extends RedPocketState {}

class UpdateMyLevelInfoEntityState extends RedPocketState {
  final RpMyLevelInfo rpMyLevelInfo;

  UpdateMyLevelInfoEntityState(this.rpMyLevelInfo);
}

class UpdateFailMyLevelInfoEntityState extends RedPocketState {}
