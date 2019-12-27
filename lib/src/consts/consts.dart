import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

class Const {
  static const String DOMAIN = 'https://api.hyn.space/';

  static const String TITAN_SCHEMA = "titan://";
  static const String TITAN_SHARE_URL_PREFIX = "https://www.hyn.space/titan/share?key=";
  static const String CIPHER_TEXT_PREFIX = "titan_cipher";
  static const String CIPHER_TOKEN_PREFIX = "titan_cls";

  static const String NEWS_DOMAIN = "https://news.hyn.space/";

  static Color PRIMARY_COLOR = HexColor("#FF259B24");

  static NumberFormat DOUBLE_NUMBER_FORMAT = new NumberFormat("#,###.##");

  static DateFormat DATE_FORMAT = new DateFormat("yy/MM/dd HH:mm");

  static const Map LANGUAGE_NAME_MAP = {
    "zh_CN": "简体中文",
    "ko_": "한글",
    "en_": "English",
  };
}

class Keys {
  static final materialAppKey = GlobalKey(debugLabel: '__app__');
  static final mainContextKey = GlobalKey(debugLabel: '__main_context__');
  static final mapContainerKey = GlobalKey(debugLabel: '__map__');
  static final mapParentKey = GlobalKey(debugLabel: '__map_parent__');
}

class PrefsKey {
  static final appLanguageCode = "app_languageCode";
  static final appCountryCode = "app_countryCode";
  static final appArea = "app_area";

  static const String FIRST_TIME_LAUNCHER_KEY = 'app_first_time_launcher';
}
