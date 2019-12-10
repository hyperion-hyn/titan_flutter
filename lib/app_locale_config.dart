import 'package:titan/generated/i18n.dart';

class AppLocaleConfig {

  static int gCurrentThemeIndex = 0;

  /// 某些地方无法 获取context ,但又需要获取国际化的字符串时,但系统切换可能导致文字不会改变,因为字符串没有在 state方法中初始化
  List<S> ss = [
    S(),
    $zh_CN(),
    $ko(),
    $en(),
  ];

  /// 当context 不存在时，通过SS而非S去获取字符串
  S get SS {
    return ss[gCurrentThemeIndex];
  }

}
