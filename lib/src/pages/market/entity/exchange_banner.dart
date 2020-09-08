import 'package:json_annotation/json_annotation.dart';

part 'exchange_banner.g.dart';


@JsonSerializable()
class ExchangeBanner extends Object {

  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'html')
  String html;

  @JsonKey(name: 'onShow')
  String onShow;

  @JsonKey(name: 'expire')
  String expire;

  ExchangeBanner(this.id,this.url,this.html,this.onShow,this.expire,);

  factory ExchangeBanner.fromJson(Map<String, dynamic> srcJson) => _$ExchangeBannerFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ExchangeBannerToJson(this);

}


