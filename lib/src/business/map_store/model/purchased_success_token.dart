import 'package:json_annotation/json_annotation.dart';

part 'purchased_success_token.g.dart';

@JsonSerializable()
class PurchasedSuccessToken {
  String token;

  PurchasedSuccessToken();


  factory PurchasedSuccessToken.fromJson(Map<String, dynamic> json) => _$PurchasedSuccessTokenFromJson(json);

  Map<String, dynamic> toJson() => _$PurchasedSuccessTokenToJson(this);


}


