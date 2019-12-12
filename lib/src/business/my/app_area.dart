import 'package:titan/generated/i18n.dart';
import 'package:titan/src/global.dart';

class AppArea {
  String key;
  Function getName;

  String get name => getName();

  AppArea(this.key, this.getName);

  static AppArea MAINLAND_CHINA_AREA = AppArea("mainland_china_area", () {
    return S.of(globalContext).mainland_china;
  });

  static AppArea OTHER_AREA = AppArea("other_area", () {
    return S.of(globalContext).other_area;
  });

  static Map<String, AppArea> APP_AREA_MAP = {MAINLAND_CHINA_AREA.key: MAINLAND_CHINA_AREA, OTHER_AREA.key: OTHER_AREA};
}
