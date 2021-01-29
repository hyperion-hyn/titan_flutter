import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:titan/src/components/app_lock/app_lock_bloc.dart';
import 'package:titan/src/components/app_lock/entity/app_lock_config.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';

class AppLockUtil {
  static void appLockSwitch(BuildContext context, bool isOn) {
    if (isOn) {
      BlocProvider.of<AppLockBloc>(context).add(LockAppEvent());
    } else {
      BlocProvider.of<AppLockBloc>(context).add(UnLockAppEvent());
    }
  }

  static Future<void> ignoreAppLock(BuildContext context, bool value) async {
    BlocProvider.of<AppLockBloc>(context).add(IgnoreAppLockEvent(value));
  }

  static Future<bool> checkEnable() async {
    var jsonStr = await AppCache.secureGetValue(
      SecurePrefsKey.APP_LOCK_CONFIG,
    );
    var config;
    if (jsonStr != null) {
      config = AppLockConfig.fromJson(json.decode(jsonStr));
    }
    if (config != null) {
      return config.walletLock.isEnabled;
    } else {
      return false;
    }
  }

  static Future<AppLockConfig> getAppLockConfig() async {
    var jsonStr = await AppCache.secureGetValue(
      SecurePrefsKey.APP_LOCK_CONFIG,
    );
    var config = AppLockConfig.fromJson(json.decode(jsonStr));
    return config;
  }

  static Future<bool> checkWalletLockPwd(String pwd) async {
    var jsonStr = await AppCache.secureGetValue(
      SecurePrefsKey.APP_LOCK_CONFIG,
    );
    try {
      var config = AppLockConfig.fromJson(json.decode(jsonStr));
      return pwd == config.walletLock.pwd;
    } catch (e) {
      return false;
    }
  }

  static Future<int> getAwayTime() async {
    var jsonStr = await AppCache.secureGetValue(
      SecurePrefsKey.APP_LOCK_CONFIG,
    );
    var config = AppLockConfig.fromJson(json.decode(jsonStr));
    if (config != null) {
      return config.walletLock.awayTime;
    } else {
      return 0;
    }
  }

  static Future<bool> checkBioAuthEnable() async {
    var jsonStr = await AppCache.secureGetValue(
      SecurePrefsKey.APP_LOCK_CONFIG,
    );
    var config = AppLockConfig.fromJson(json.decode(jsonStr));
    if (config != null) {
      return config.walletLock.isBioAuthEnabled;
    } else {
      return false;
    }
  }

  static setBioAuth(bool enabled) async {
    var jsonStr = await AppCache.secureGetValue(
      SecurePrefsKey.APP_LOCK_CONFIG,
    );
    var config = AppLockConfig.fromJson(json.decode(jsonStr));
    if (config != null) {
      config.walletLock.isBioAuthEnabled = enabled;
      await AppCache.secureSaveValue(
        SecurePrefsKey.APP_LOCK_CONFIG,
        json.encode(config.toJson()),
      );
    }
  }
}
