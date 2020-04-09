import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/config/consts.dart';

String getRequestLang() {
  var locale = SettingInheritedModel.of(Keys.mapContainerKey.currentContext)?.languageModel?.locale;
  if (locale == null) {
    return "zh";
  } else if (locale.countryCode == null || locale.countryCode == "") {
    return locale.languageCode;
  } else {
    return "${locale.languageCode}_${locale.countryCode}";
  }
}

class MeUtils {
  /// 后台算力单位转成UI显示单位
  static double powerForShow(int power) {
    if(power == null) {
      return 0;
    }
    return power / 10.0;
  }
}