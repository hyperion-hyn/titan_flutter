import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

class Const {
  static const String DOMAIN = 'https://api.hyn.space/';
  static const String DOMAIN_MAP3_LOCAL = 'http://10.10.1.115:5000/';

  static const String TITAN_SCHEMA = "titan://";
  static const String TITAN_SHARE_URL_PREFIX = "https://www.hyn.space/titan/share?key=";
  static const String CIPHER_TEXT_PREFIX = "titan_cipher";
  static const String CIPHER_TOKEN_PREFIX = "titan_cls";

  static const String NEWS_DOMAIN = "https://news.hyn.space/";

  static Color PRIMARY_COLOR = HexColor("#FF259B24");

  static NumberFormat DOUBLE_NUMBER_FORMAT = new NumberFormat("#,###.##");

  static DateFormat DATE_FORMAT = new DateFormat("yy/MM/dd HH:mm");

  //ncov
  static const kNcovMapStyleCn = 'https://cn.tile.map3.network/ncov.json';

  //white
  static const kWhiteMapStyleCn = 'https://cn.tile.map3.network/see-it-all-boundary-cdn-en.json';

//  static const kWhiteMapStyleCn = 'http://10.10.1.115:9999/titan-see-it-all.json';
  static const kWhiteMapStyle = 'https://static.hyn.space/maptiles/see-it-all-boundary-cdn-en.json';

  //black
  static const kBlackMapStyleCn = "https://cn.tile.map3.network/fiord-color.json";
  static const kBlackMapStyle = "https://static.hyn.space/maptiles/fiord-color.json";
  static const kNCovMapStyle = 'https://cn.tile.map3.network/ncov_v1.json';

  static const Map LANGUAGE_NAME_MAP = {
    "zh_CN": "简体中文",
    "ko_": "한글",
    "en_": "English",
  };

  static const String POI_POLICY = "https://api.hyn.space/map-collector/pol-policy";
  static const String PRIVACY_POLICY = "https://api.hyn.space/map-collector/upload/privacy-policy";
}

class Keys {
  static final materialAppKey = GlobalKey(debugLabel: '__app__');
  static final rootKey = GlobalKey(debugLabel: '__root_page__');
  static final homePageKey = GlobalKey(debugLabel: '__home_page__');
  static final mapContainerKey = GlobalKey(debugLabel: '__map__');
  static final mapParentKey = GlobalKey(debugLabel: '__map_parent__');
  static final homePanelKey = GlobalKey(debugLabel: '__home_panel_parent__');
  static final mapDraggablePanelKey = GlobalKey(debugLabel: 'mapDraggablePanelKey');
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

  //wallet
  static const String ACTIVATED_WALLET_FILE_NAME = 'default_wallet_file_name';
  static final appLanguageCode = "app_languageCode";
  static final appCountryCode = "app_countryCode";
  static final appArea = "app_area";
  static final mapboxCountryCode = "mapbox_countryCode";
  static final lastPosition = "last_map_position";

  static final lastAnnouncement = 'last_announcement';
  static final newsUpdateTime = 'news_update_time';
}

enum Status { idle, loading, success, failed, cancelled }

class RouteProfile {
  static final String driving = 'driving';
  static final String walking = 'walking';
  static final String cycling = 'cycling';
}
