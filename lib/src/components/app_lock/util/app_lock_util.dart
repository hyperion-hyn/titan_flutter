import 'dart:convert';

import 'package:titan/src/components/app_lock/entity/app_lock_config.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';

class AppLockUtil {
  static Future<bool> checkWalletLockPwd(String pwd) async {
    var jsonStr = await AppCache.secureGetValue(
      SecurePrefsKey.APP_LOCK_CONFIG,
    );
    var config = AppLockConfig.fromJson(json.decode(jsonStr));
    if (config != null) {
      return pwd == config.walletLock.pwd;
    } else {
      return false;
    }
  }
}
