import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'business/wallet/model/wallet_vo.dart';

/// The global [EventBus] object.
EventBus eventBus = EventBus();

var logger = Logger();

double bottomBarHeight = 65;

///some const
const safeAreaBottomPadding = 24.0;
const saveAreaTopPadding = 32.0;

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

String createWalletNameTemp = "";
String createWalletPasswordTemp = "";
String createWalletMnemonicTemp = "";

const String QUOTE_UNIT = "CNY";
const String QUOTE_UNIT_SYMBOL = "¥";

WalletVo currentWalletVo;
