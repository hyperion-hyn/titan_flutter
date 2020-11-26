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

  RPStatistics(
    this.global,
    this.self,
    this.rpContractInfo,
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
  String totalAmount;

  @JsonKey(name: 'total_rp')
  String totalRp;

  @JsonKey(name: 'yesterday')
  String yesterday;

  String get totalStakingHynStr => FormatUtil.weiToEtherStr(totalStakingHyn) ?? '0';

  String get totalAmountStr => FormatUtil.weiToEtherStr(totalAmount) ?? '0';

  String get totalRpStr => FormatUtil.weiToEtherStr(totalRp) ?? '0';

  String get yesterdayStr => FormatUtil.weiToEtherStr(yesterday) ?? '0';

  Self(
    this.totalStakingHyn,
    this.totalAmount,
    this.totalRp,
    this.yesterday,
  );

  factory Self.fromJson(Map<String, dynamic> srcJson) => _$SelfFromJson(srcJson);

  Map<String, dynamic> toJson() => _$SelfToJson(this);
}

@JsonSerializable()
class Rp_contract_info extends Object {
  @JsonKey(name: 'ratio')
  String ratio;

  @JsonKey(name: 'hyn_per_rp')
  String hynPerRp;

  @JsonKey(name: 'release_day')
  int releaseDay;

  @JsonKey(name: 'staking_day')
  int stakingDay;

  Rp_contract_info(
    this.ratio,
    this.hynPerRp,
    this.releaseDay,
    this.stakingDay,
  );

  factory Rp_contract_info.fromJson(Map<String, dynamic> srcJson) => _$Rp_contract_infoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$Rp_contract_infoToJson(this);
}
