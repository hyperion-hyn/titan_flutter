import 'package:json_annotation/json_annotation.dart';

part 'app_lock_config.g.dart';

@JsonSerializable()
class AppLockConfig extends Object {
  @JsonKey(name: 'walletLock')
  WalletLock walletLock;

  AppLockConfig(
    this.walletLock,
  );

  factory AppLockConfig.fromDefault() => AppLockConfig(WalletLock(false, false, null, 0, false));

  factory AppLockConfig.fromJson(Map<String, dynamic> srcJson) => _$AppLockConfigFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AppLockConfigToJson(this);
}

class WalletLock extends Object {
  @JsonKey(name: 'isEnabled')
  bool isEnabled;

  @JsonKey(name: 'isOn')
  bool isOn;

  @JsonKey(name: 'pwd')
  String pwd;

  @JsonKey(name: 'awayTime')
  int awayTime;

  @JsonKey(name: 'isBioAuthEnabled')
  bool isBioAuthEnabled;

  WalletLock(
    this.isEnabled,
    this.isOn,
    this.pwd,
    this.awayTime,
    this.isBioAuthEnabled,
  );

  factory WalletLock.fromJson(Map<String, dynamic> srcJson) => _$WalletLockFromJson(srcJson);

  Map<String, dynamic> toJson() => _$WalletLockToJson(this);
}
