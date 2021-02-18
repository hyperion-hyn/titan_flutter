import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';

class PolicyUtil {
  static Future<bool> checkConfirmWalletPolicy() async {
    var isConfirm = await AppCache.getValue(
      PrefsKey.IS_CONFIRM_WALLET_POLICY,
    );
    return isConfirm == null || !isConfirm;
  }

  static Future<bool> checkConfirmExchangePolicy() async {
    var isConfirm = await AppCache.getValue(
      PrefsKey.IS_CONFIRM_DEX_POLICY,
    );
    return isConfirm == null || !isConfirm;
  }
}
