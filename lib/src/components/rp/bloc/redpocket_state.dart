import 'package:meta/meta.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_my_level_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_statistics.dart';

@immutable
abstract class RedPocketState {}

class InitialAtlasState extends RedPocketState {}

class UpdateMyLevelInfoState extends RedPocketState {
  final RpMyLevelInfo rpMyLevelInfo;

  UpdateMyLevelInfoState(this.rpMyLevelInfo);
}

class UpdateStatisticsState extends RedPocketState {
  final RPStatistics rpStatistics;

  UpdateStatisticsState(this.rpStatistics);
}


class UpdateFailState extends RedPocketState {}

class ClearMyLevelInfoState extends RedPocketState {}
