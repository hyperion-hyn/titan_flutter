import 'dart:convert';

import 'package:titan/src/components/app_lock/entity/app_lock_config.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';

class AppLockUtil {
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
