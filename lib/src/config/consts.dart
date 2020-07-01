import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:titan/config.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/plugins/wallet/contract_const.dart';

import '../../env.dart';

class Const {
  static String get DOMAIN {
    return 'https://api.hyn.space/';
  }

  static String get NODE_DOMAIN {
    if (env.buildType == BuildType.DEV) {
      return Config.NODE_API_URL_TEST;
    } else {
      return Config.NODE_API_URL;
    }
  }

  static const String TITAN_SCHEMA = "titan://";
  static const String TITAN_SHARE_URL_PREFIX =
      "https://www.hyn.space/titan/share?key=";
  static const String CIPHER_TEXT_PREFIX = "titan_cipher";
  static const String CIPHER_TOKEN_PREFIX = "titan_cls";

  static const String NEWS_DOMAIN = "https://news.hyn.space/";

  static Color PRIMARY_COLOR = HexColor("#FF259B24");

//  static NumberFormat DOUBLE_NUMBER_FORMAT = new NumberFormat("#,###.##");

  static DateFormat DATE_FORMAT = new DateFormat("yy/MM/dd HH:mm");

  //ncov
  static const kNcovMapStyleCn = 'https://cn.tile.map3.network/ncov.json';

  //white
  static const kWhiteMapStyleCn =
      'https://cn.tile.map3.network/see-it-all-boundary-cdn-en.json';

//  static const kWhiteMapStyleCn = 'http://10.10.1.115:9999/titan-see-it-all.json';
  static const kWhiteMapStyle =
      'https://static.hyn.space/maptiles/see-it-all-boundary-cdn-en.json';

  //black
  static const kBlackMapStyleCn =
      "https://cn.tile.map3.network/fiord-color.json";
  static const kBlackMapStyle =
      "https://static.hyn.space/maptiles/fiord-color.json";
  static const kNCovMapStyle = 'https://cn.tile.map3.network/ncov_v1.json';

  static const String POI_POLICY =
      "https://api.hyn.space/map-collector/pol-policy";
  static const String PRIVACY_POLICY =
      "https://api.hyn.space/map-collector/upload/privacy-policy";
  static const String APP_POLICY =
      'https://github.com/hyperion-hyn/titan_flutter/blob/master/LICENSE';
}

class Keys {
  static final materialAppKey = GlobalKey(debugLabel: '__app__');
  static final rootKey = GlobalKey(debugLabel: '__root_page__');
  static final homePageKey = GlobalKey(debugLabel: '__home_page__');
  static final scaffoldMap = GlobalKey(debugLabel: '__scaffold_map__');
  static final mapContainerKey = GlobalKey(debugLabel: '__map__');
  static final mapParentKey = GlobalKey(debugLabel: '__map_parent__');
  static final mapHeatKey = GlobalKey(debugLabel: '__map_heat__');
  static final homePanelKey = GlobalKey(debugLabel: '__home_panel_parent__');
  static final mapDraggablePanelKey =
      GlobalKey(debugLabel: 'mapDraggablePanelKey');
}

class PrefsKey {
//  static final appLanguageCode = "app_languageCode";
//  static final appCountryCode = "app_countryCode";
//  static final appArea = "app_area";

  static const String FIRST_TIME_LAUNCHER_KEY = 'app_first_time_launcher';

  //setting
  static const String SETTING_LANGUAGE = 'setting_language';
  static const String SETTING_AREA = 'setting_area';
  static const String SETTING_QUOTE_SIGN = 'setting_quete_sign';
  static const String SETTING_SYSTEM_CONFIG = 'setting_system_config';

  //wallet
  static const String ACTIVATED_WALLET_FILE_NAME = 'default_wallet_file_name';
  static final walletBalance = 'wallet_balance';
  static final walletBitcoinCreate = 'wallet_bitcoin_create';

  static final appLanguageCode = "app_languageCode";
  static final appCountryCode = "app_countryCode";
  static final appArea = "app_area";
  static final mapboxCountryCode = "mapbox_countryCode";
  static final lastPosition = "last_map_position";

  static final lastAnnouncement = 'last_announcement';
  static final newsUpdateTime = 'news_update_time';

  static final WALLET_PUB_KEY_PREFIX_KEY = 'wallet_pub_';

  ///auth
  static const String AUTH_CONFIG = 'auth_config';
}

class SecurePrefsKey {
  static final String WALLET_PWD_KEY_PREFIX = 'wallet_pwd_';
  static final String AUTH_LOCK_PATTERN_KEY = 'lockpattern';
  static final String MY_PUBLIC_KEY = 'my_public_key';
  static final String MY_PRIVATE_KEY = 'my_private_key';
}

enum Status { idle, loading, success, failed, cancelled }

class RouteProfile {
  static final String driving = 'driving';
  static final String walking = 'walking';
  static final String cycling = 'cycling';
}

class PlatformErrorCode {
  static const String PASSWORD_WRONG = '1';
  static const String PARAMETERS_WRONG = '2';
}
