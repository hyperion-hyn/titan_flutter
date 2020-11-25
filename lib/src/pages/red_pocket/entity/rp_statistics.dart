import 'package:json_annotation/json_annotation.dart';

part 'rp_statistics.g.dart';


@JsonSerializable()
class RPStatistics extends Object {

  @JsonKey(name: 'global')
  Global global;

  @JsonKey(name: 'self')
  Self self;

  RPStatistics(this.global,this.self,);

  factory RPStatistics.fromJson(Map<String, dynamic> srcJson) => _$RPStatisticsFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RPStatisticsToJson(this);

}


@JsonSerializable()
class Global extends Object {

  @JsonKey(name: 'hyn')
  int hyn;

  @JsonKey(name: 'total')
  int total;

  @JsonKey(name: 'transmit')
  int transmit;

  Global(this.hyn,this.total,this.transmit,);

  factory Global.fromJson(Map<String, dynamic> srcJson) => _$GlobalFromJson(srcJson);

  Map<String, dynamic> toJson() => _$GlobalToJson(this);

}


@JsonSerializable()
class Self extends Object {

  @JsonKey(name: 'total_hyn')
  int totalHyn;

  @JsonKey(name: 'total_rp')
  int totalRp;

  @JsonKey(name: 'yesterday')
  int yesterday;

  Self(this.totalHyn,this.totalRp,this.yesterday,);

  factory Self.fromJson(Map<String, dynamic> srcJson) => _$SelfFromJson(srcJson);

  Map<String, dynamic> toJson() => _$SelfToJson(this);

}


