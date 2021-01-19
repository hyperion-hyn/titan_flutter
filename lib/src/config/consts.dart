import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:titan/config.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

import '../../env.dart';

class Const {
  static String get DOMAIN {
    return 'https://api.hyn.space/';
  }

  static String get LOCAL_DOMAIN {
    return Config.ATLAS_API_URL_TEST;
  }

  static const String MARKET_DOMAIN = 'https://api.huobi.br.com/';

  static String get NODE_DOMAIN {
    if (env.buildType == BuildType.DEV) {
      return Config.NODE_API_URL_TEST;
    } else {
      return Config.NODE_API_URL;
    }
  }

  static String get EXCHANGE_DOMAIN {
    if (env.buildType == BuildType.DEV) {
      return Config.EXCHANGE_DOMAIN_TEST;
    } else {
      return Config.EXCHANGE_DOMAIN;
    }
  }

  static String get WS_DOMAIN {
    if (env.buildType == BuildType.DEV) {
      return Config.WS_DOMAIN_TEST;
    } else {
      return Config.WS_DOMAIN;
    }
  }

  static String get ATLAS_DOMAIN {
    if (env.buildType == BuildType.DEV) {
      return Config.ATLAS_API_URL_TEST;
    } else {
      return Config.ATLAS_API_URL;
    }
  }

  static String get RP_DOMAIN {
    if (env.buildType == BuildType.DEV) {
      return Config.RP_API_URL_TEST;
    } else {
      return Config.RP_API_URL;
    }
  }


  static String get CONTRIBUTIONS_DOMAIN {
    if (env.buildType == BuildType.DEV) {
      return Config.CONTRIBUTIONS_API_URL_TEST;
    } else {
      return Config.CONTRIBUTIONS_API_URL;
    }
  }

  static const String TITAN_SCHEMA = "titan://";
  static const String TITAN_SHARE_URL_PREFIX =
      'https://www.hyn.mobi/titan/sharev2/?key=';
  static const String CIPHER_TEXT_PREFIX = "titan_cipher";
  static const String CIPHER_TOKEN_PREFIX = "titan_cls";

  static const String NEWS_DOMAIN = "https://news.hyn.space/";

  static Color PRIMARY_COLOR = HexColor("#FF259B24");

//  static NumberFormat DOUBLE_NUMBER_FORMAT = new NumberFormat("#,###.##");

  static DateFormat DATE_FORMAT = new DateFormat("yy/MM/dd HH:mm");
  static DateFormat DAY_FORMAT = new DateFormat("yyyy/MM/dd");

  //ncov
  static const kNcovMapStyleCn = 'https://cn.tile.map3.network/ncov.json';

  //white
  // static const kWhiteMapStyleCn =
  //     'https://cn.tile.map3.network/see-it-all-boundary-cdn-en.json';
  static String get kWhiteMapStyleCn {
    if (env.buildType == BuildType.DEV) {
      return 'https://cn.tile.map3.network/see-it-all-rp-test.json';
    } else {
      return 'https://cn.tile.map3.network/see-it-all-rp.json';
    }
  }

  // static const kWhiteMapStyle =
  //     'https://static.hyn.space/maptiles/see-it-all-boundary-cdn-en.json';
  static String get kWhiteMapStyle {
    if (env.buildType == BuildType.DEV) {
      return 'https://static.hyn.space/maptiles/see-it-all-rp-test.json';
    } else {
      return 'https://static.hyn.space/maptiles/see-it-all-rp.json';
    }
  }

//white-without
  static const kWhiteWithoutMapStyleCn =
      'https://cn.tile.map3.network/see-it-all-boundary-cdn-without-contribution-en.json';

  static const kWhiteWithoutMapStyle =
      'https://static.hyn.space/maptiles/see-it-all-boundary-cdn-without-contribution-en.json';

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
  static const String HELP_PAGE = "http://h.hyn.space/helpPage";
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
  static const String SETTING_SYSTEM_THEME = 'setting_system_theme';

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

  static final WALLET_USE_DIGITS_PWD_PREFIX = 'digits_pwd';

  ///auth
  static const String AUTH_CONFIG = 'auth_config';

  //contribution
  static const String VERIFY_DATE = 'verify_date';

  static const String SHARED_PREF_GAS_PRICE_KEY = "shared_pref_gas_price_key";
  static const String SHARED_PREF_BTC_GAS_PRICE_KEY =
      "shared_pref_btc_gas_price_key";

  static const String SHARED_PREF_GAS_FEE_KEY = "shared_pref_gas_fee_key";

  // Exchange
  static const String PERIOD_CURRENT_INDEX = 'periodCurrentIndex';
  static const String KLINE_MAIN_STATE = 'mainState';
  static const String KLINE_SECONDARY_STATE = 'secondaryState';

  static const String CACHE_MARKET_ITEM_LIST = 'cache_market_item_list_v2';
  static const String CACHE_EXCHANGE_COIN_LIST = 'cache_exchange_coin_list';
  
  static const String EXCHANGE_ACCOUNT = 'exchange_account';
  static const String EXCHANGE_ACCOUNT_LAST_AUTH_TIME =
      'exchange_account_last_auth_time';
  // static const String PENDING_TRANSFER_KEY_PREFIX = 'pending_transfer_key_';
  static const String PENDING_TRANSACTIONS_KEY_PREFIX = 'pending_transactions_key_';

  static const String EXCHANGE_ACCOUNT_ABNORMAL = 'exchange_account_abnormal_';

  
  ///Policy
  static const String IS_CONFIRM_WALLET_POLICY = 'wallet_policy_confirmed';
  static const String IS_CONFIRM_DEX_POLICY = 'dex_policy_confirmed';

  static const String WALLET_ICON_LAST_KEY = "wallet_icon_last_key";

}

class SecurePrefsKey {
  ///complete key:  WALLET_PWD_KEY_PREFIX + wallet.getEthAccount().address
  static final String WALLET_PWD_KEY_PREFIX = 'wallet_pwd_';
  static final String AUTH_LOCK_PATTERN_KEY = 'lockpattern';
  static final String MY_PUBLIC_KEY = 'my_public_key';
  static final String MY_PRIVATE_KEY = 'my_private_key';

  ///complete key:  WALLET_P2P_PUB_KEY_PREFIX + wallet.getEthAccount().address
  static final String WALLET_P2P_PUB_KEY_PREFIX = 'wallet_p2p_pub_key_';
  static final String WALLET_P2P_DECOMP_PUB_KEY_PREFIX =
      'wallet_p2p_decomp_pub_key_';
}

enum Status { idle, loading, success, failed, cancelled }

class RouteProfile {
  static final String driving = 'driving';
  static final String walking = 'walking';
  static final String cycling = 'cycling';
}
