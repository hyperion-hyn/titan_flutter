import 'package:flutter/widgets.dart';

class Const {
  static const String DOMAIN = 'https://api.hyn.space/';

  static const String TITAN_SCHEMA = "titan://";
  static const String TITAN_SHARE_URL_PREFIX = "https://www.hyn.space/titan/share?key=";
  static const String CIPHER_TEXT_PREFIX = "titan_cipher";
  static const String CIPHER_TOKEN_PREFIX = "titan_cls";
}

class Keys {
  static final materialAppKey = GlobalKey(debugLabel: '__app__');
  static final mainContextKey = GlobalKey(debugLabel: '__main_context__');
}
