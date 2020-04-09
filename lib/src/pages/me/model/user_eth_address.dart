import 'package:json_annotation/json_annotation.dart';


part 'user_eth_address.g.dart';

@JsonSerializable()
class UserEthAddress {

  String address;
  @JsonKey(name: "qr_code")
  String qrCode;

  UserEthAddress(this.address, this.qrCode);


  factory UserEthAddress.fromJson(Map<String, dynamic> json) => _$UserEthAddressFromJson(json);

  Map<String, dynamic> toJson() => _$UserEthAddressToJson(this);


}