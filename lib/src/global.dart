import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:titan/src/business/me/model/parent_user.dart';
import 'package:titan/src/business/me/model/user_info.dart';

import 'business/wallet/model/wallet_vo.dart';
import 'package:titan/app_locale_config.dart';

/// The global [EventBus] object.
EventBus eventBus = EventBus();

var logger = Logger();

double bottomBarHeight = 65;

var locale_config = AppLocaleConfig();

///some const
const safeAreaBottomPadding = 24.0;
const saveAreaTopPadding = 32.0;

int LOGIN_STATUS = 0; //0:还没有读取到数据 1：没有登录 2：登录

UserInfo LOGIN_USER_INFO = UserInfo("", "", "", 0, 0, 0, 0, 0, 0, 0, 0, "", 0, ParentUser("", ""), 0);

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

String createWalletNameTemp = "";
String createWalletPasswordTemp = "";
String createWalletMnemonicTemp = "";

const String QUOTE_UNIT = "CNY";
const String QUOTE_UNIT_SYMBOL = "¥";

WalletVo currentWalletVo;

String createWalletPopUtilName;

bool isRechargeByTianWalletFinish = false;
