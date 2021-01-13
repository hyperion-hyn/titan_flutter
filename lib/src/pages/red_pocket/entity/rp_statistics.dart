import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/utils/format_util.dart';

part 'rp_statistics.g.dart';

@JsonSerializable()
class RPStatistics extends Object {
  @JsonKey(name: 'global')
  Global global;

  @JsonKey(name: 'self')
  Self self;

  @JsonKey(name: 'rp_contract_info')
  Rp_contract_info rpContractInfo;

  @JsonKey(name: 'rp_holding_contract_info')
  Rp_holding_contract_info rpHoldingContractInfo;

  @JsonKey(name: 'airdrop_info')
  Airdrop_info airdropInfo;

  @JsonKey(name: 'level_counts')
  List<LevelCounts> levelCounts;

  RPStatistics(
    this.global,
    this.self,
    this.rpContractInfo,
    this.rpHoldingContractInfo,
    this.airdropInfo,
    this.levelCounts,
  );

  factory RPStatistics.fromJson(Map<String, dynamic> srcJson) => _$RPStatisticsFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RPStatisticsToJson(this);
}

@JsonSerializable()
class Global extends Object {
  @JsonKey(name: 'total_staking_hyn')
  String totalStakingHyn;

  @JsonKey(name: 'transmit')
  String transmit;

  @JsonKey(name: 'total_transmit')
  String totalTransmit;

  String get totalStakingHynStr => FormatUtil.weiToEtherStr(totalStakingHyn) ?? '0';

  String get transmitStr => FormatUtil.weiToEtherStr(transmit) ?? '0';

  String get totalTransmitStr => FormatUtil.weiToEtherStr(totalTransmit) ?? '0';

  Global(
    this.totalStakingHyn,
    this.transmit,
    this.totalTransmit,
  );

  factory Global.fromJson(Map<String, dynamic> srcJson) => _$GlobalFromJson(srcJson);

  Map<String, dynamic> toJson() => _$GlobalToJson(this);
}

@JsonSerializable()
class Self extends Object {
  @JsonKey(name: 'total_staking_hyn')
  String totalStakingHyn;

  @JsonKey(name: 'total_amount')
  int totalAmount;

  @JsonKey(name: 'total_rp')
  String totalRp;

  @JsonKey(name: 'yesterday')
  String yesterday;

  @JsonKey(name: 'friends')
  int friends;

  String get totalStakingHynStr => FormatUtil.weiToEtherStr(totalStakingHyn) ?? '0';

  String get totalAmountStr => FormatUtil.weiToEtherStr(totalAmount) ?? '0';

  String get totalRpStr => FormatUtil.weiToEtherStr(totalRp) ?? '0';

  String get yesterdayStr => FormatUtil.weiToEtherStr(yesterday) ?? '0';

  Self(
    this.totalStakingHyn,
    this.totalAmount,
    this.totalRp,
    this.yesterday,
    this.friends,
  );

  factory Self.fromJson(Map<String, dynamic> srcJson) => _$SelfFromJson(srcJson);

  Map<String, dynamic> toJson() => _$SelfToJson(this);
}

@JsonSerializable()
class Rp_contract_info extends Object {
  @JsonKey(name: 'base_rp')
  String baseRp;

  @JsonKey(name: 'hyn_per_rp')
  String hynPerRp;

  @JsonKey(name: 'release_day')
  int releaseDay;

  @JsonKey(name: 'staking_day')
  int stakingDay;

  @JsonKey(name: 'drop_on_percent')
  int dropOnPercent;

  @JsonKey(name: 'pool_percent')
  int poolPercent;

  String get hynPerRpStr => FormatUtil.weiToEtherStr(hynPerRp) ?? '0';

  String get baseRpStr => FormatUtil.weiToEtherStr(baseRp) ?? '0';

  Rp_contract_info(
    this.baseRp,
    this.hynPerRp,
    this.releaseDay,
    this.stakingDay,
    this.dropOnPercent,
    this.poolPercent,
  );

  factory Rp_contract_info.fromJson(Map<String, dynamic> srcJson) => _$Rp_contract_infoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$Rp_contract_infoToJson(this);
}

@JsonSerializable()
class Rp_holding_contract_info extends Object {
  @JsonKey(name: 'promotion_supply_ratio')
  String promotionSupplyRatio;

  @JsonKey(name: 'total_burning')
  String totalBurning;

  @JsonKey(name: 'total_holding')
  String totalHolding;

  @JsonKey(name: 'total_supply')
  String totalSupply;

  @JsonKey(name: 'random_min_level')
  int randomMinLevel;

  @JsonKey(name: 'gradient_ratio')
  double gradientRatio;

  String get totalBurningStr => FormatUtil.weiToEtherStr(totalBurning) ?? '--';

  String get totalHoldingStr => FormatUtil.weiToEtherStr(totalHolding) ?? '--';

  String get totalSupplyStr => FormatUtil.weiToEtherStr(totalSupply) ?? '0';

  Rp_holding_contract_info(
    this.promotionSupplyRatio,
    this.totalBurning,
    this.totalHolding,
    this.totalSupply,
    this.randomMinLevel,
    this.gradientRatio,
  );

  factory Rp_holding_contract_info.fromJson(Map<String, dynamic> srcJson) =>
      _$Rp_holding_contract_infoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$Rp_holding_contract_infoToJson(this);
}

@JsonSerializable()
class Airdrop_info extends Object {
  @JsonKey(name: 'total_amount')
  String totalAmount;

  @JsonKey(name: 'today_amount')
  String todayAmount;

  @JsonKey(name: 'miss_amount')
  String missRpAmount;

  @JsonKey(name: 'yesterday_amount')
  String yesterdayAmount;

  String get totalAmountStr => FormatUtil.weiToEtherStr(totalAmount) ?? '--';

  String get todayAmountStr => FormatUtil.weiToEtherStr(todayAmount) ?? '--';

  String get yesterdayRpAmountStr => FormatUtil.weiToEtherStr(yesterdayAmount) ?? '--';

  String get missRpAmountStr => FormatUtil.weiToEtherStr(missRpAmount) ?? '--';

  Airdrop_info(
    this.totalAmount,
    this.missRpAmount,
    this.todayAmount,
    this.yesterdayAmount,
  );

  factory Airdrop_info.fromJson(Map<String, dynamic> srcJson) => _$Airdrop_infoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$Airdrop_infoToJson(this);
}

@JsonSerializable()
class LevelCounts extends Object {
  @JsonKey(name: 'count')
  int count;

  @JsonKey(name: 'level')
  int level;

  LevelCounts(
    this.count,
    this.level,
  );

  factory LevelCounts.fromJson(Map<String, dynamic> srcJson) => _$LevelCountsFromJson(srcJson);

  Map<String, dynamic> toJson() => _$LevelCountsToJson(this);
}
