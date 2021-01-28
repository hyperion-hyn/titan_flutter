// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_lock_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppLockConfig _$AppLockConfigFromJson(Map<String, dynamic> json) {
  return AppLockConfig(
    json['walletLock'] == null
        ? null
        : WalletLock.fromJson(json['walletLock'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$AppLockConfigToJson(AppLockConfig instance) =>
    <String, dynamic>{
      'walletLock': instance.walletLock,
    };

WalletLock _$WalletLockFromJson(Map<String, dynamic> json) {
  return WalletLock(
    json['isEnabled'] as bool,
    json['isOn'] as bool,
    json['pwd'] as String,
    json['pwdHint'] as String,
    json['awayTime'] as int,
    json['isBioAuthEnabled'] as bool,
  );
}

Map<String, dynamic> _$WalletLockToJson(WalletLock instance) =>
    <String, dynamic>{
      'isEnabled': instance.isEnabled,
      'isOn': instance.isOn,
      'pwd': instance.pwd,
      'pwdHint': instance.pwdHint,
      'awayTime': instance.awayTime,
      'isBioAuthEnabled': instance.isBioAuthEnabled,
    };
