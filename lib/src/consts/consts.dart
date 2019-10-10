import 'package:flutter/widgets.dart';

class Const {
  static const String DOMAIN = 'https://api.hyn.space/';

  static const String TITAN_SCHEMA = "titan://";
  static const String TITAN_SHARE_URL_PREFIX = "https://www.hyn.space/titan/share?key=";
  static const String CIPHER_TEXT_PREFIX = "titan_cipher";
  static const String CIPHER_TOKEN_PREFIX = "titan_cls";



  static const String MAP_STORE_DOMAIN = "https://store.map3.network/";
//    static const String MAP_STORE_DOMAIN = "http://10.10.1.119:3000/"
}

class Keys {
  static final materialAppKey = GlobalKey(debugLabel: '__app__');
  static final mainContextKey = GlobalKey(debugLabel: '__main_context__');
  static final mapKey = GlobalKey(debugLabel: '__map__');
}
