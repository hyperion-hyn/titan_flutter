import 'package:json_annotation/json_annotation.dart';

part 'exchange_account.g.dart';

@JsonSerializable()
class ExchangeAccount extends Object {
  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'email')
  String email;

  @JsonKey(name: 'nickname')
  String nickname;

  @JsonKey(name: 'username')
  String username;

  @JsonKey(name: 'country')
  String country;

  @JsonKey(name: 'activate')
  String activate;

  @JsonKey(name: 'pn')
  String pn;

  @JsonKey(name: 'mtime')
  String mtime;

  @JsonKey(name: 'ctime')
  String ctime;

  @JsonKey(name: 'reg_type')
  String regType;

  @JsonKey(name: 'mobile')
  String mobile;

  @JsonKey(name: 'gesture_token')
  int gestureToken;

  @JsonKey(name: 'beNew')
  int beNew;

  ExchangeAccount(
    this.id,
    this.email,
    this.nickname,
    this.username,
    this.country,
    this.activate,
    this.pn,
    this.mtime,
    this.ctime,
    this.regType,
    this.mobile,
    this.gestureToken,
    this.beNew,
  );

  factory ExchangeAccount.fromJson(Map<String, dynamic> srcJson) =>
      _$ExchangeAccountFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ExchangeAccountToJson(this);
}
