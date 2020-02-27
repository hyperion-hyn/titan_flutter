import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/business/my/app_area.dart';
import 'business/wallet/model/wallet_vo.dart';

/// The global [EventBus] object.
EventBus eventBus = EventBus();

var logger = Logger();

//double bottomBarHeight = 65;

///some const
const safeAreaBottomPadding = 24.0;
const saveAreaTopPadding = 32.0;

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
String createWalletPopUtilName;

String createWalletNameTemp = "";
String createWalletPasswordTemp = "";
String createWalletMnemonicTemp = "";

//String QUOTE_UNIT = appLocale.languageCode == "zh" ? "CNY" : "USD";
//String QUOTE_UNIT_SYMBOL = appLocale.languageCode == "zh" ? "¥" : "\$";

String get QUOTE_UNIT {
  return appLocale.languageCode == "zh" ? "CNY" : "USD";
}

String get QUOTE_UNIT_SYMBOL {
  return appLocale.languageCode == "zh" ? "¥" : "\$";
}

var isUpdateAnnounce = false;

WalletVo currentWalletVo;
Locale appLocale;
BuildContext globalContext = null;
Locale defaultLocale = Locale("zh","CN");

AppArea currentAppArea = AppArea.MAINLAND_CHINA_AREA;

final String ROUTE_CONFIRM_POSITION_PAGE = "route_confirm_position_page";
LatLng recentlyLocation = LatLng(23.10901,113.31799);
