import 'package:meta/meta.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_my_level_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_promotion_rule_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_share_config_entity.dart';
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

class UpdatePromotionRuleState extends RedPocketState {
  final RpPromotionRuleEntity rpPromotionRule;

  UpdatePromotionRuleState(this.rpPromotionRule);
}

class UpdateShareConfigState extends RedPocketState {
  final RpShareConfigEntity rpShareConfig;

  UpdateShareConfigState(this.rpShareConfig);
}

class UpdateFailState extends RedPocketState {}

class ClearMyLevelInfoState extends RedPocketState {}
