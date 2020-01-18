import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/components/root_page_control_component/root_page_control_component.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/config/routes.dart';
import 'package:titan/src/pages/wallet/wallet_create_new_account_page.dart';
import 'package:titan/src/pages/wallet/wallet_import_account_page.dart';
import 'package:titan/src/pages/wallet/wallet_manager/bloc/bloc.dart';
import 'package:titan/src/pages/wallet/wallet_manager/wallet_manager_page.dart';
import 'package:titan/src/pages/wallet/wallet_send_confirm_page.dart';
import 'package:titan/src/pages/wallet/wallet_send_page.dart';
import 'package:titan/src/pages/wallet/wallet_show_account_widget.dart';

import 'consts.dart';

var rootHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return RootPageControlComponent(key: Keys.homePageKey);
});

//wallet
var createWalletHandler = Handler(handlerFunc: (context, params) {
  _cacheOrClearEntryWalletRouteName(params);
  return CreateAccountPage();
});

var importWalletHandler = Handler(handlerFunc: (context, params) {
  _cacheOrClearEntryWalletRouteName(params);
  return ImportAccountPage();
});

void _cacheOrClearEntryWalletRouteName(params) {
  var url = params["entryRouteName"]?.first;
  if (url != null) {
    url = Uri.decodeComponent(url);
  }
  Routes.createOrImportWalletEntryRouteName = url;
}

var walletAccountDetailHandler = Handler(handlerFunc: (context, params) {
  return ShowAccountPage(params['coinVo']?.first);
});

var walletAccountSendTransactionHandler = Handler(handlerFunc: (context, params) {
  return WalletSendPage(params['coinVo']?.first, params['backRouteName']?.first);
});

var transferConfirmHandler = Handler(handlerFunc: (context, params) {
  return WalletSendConfirmPage(
      params['coinVo']?.first, double.parse(params['transferAmount']?.first ?? '0'), params['receiverAddress']?.first,
      backRouteName: params['backRouteName']?.first);
});

var managerWalletHandler = Handler(
    handlerFunc: (context, params) =>
        BlocProvider<WalletManagerBloc>(create: (context) => WalletManagerBloc(), child: WalletManagerPage()));

//var demoRouteHandler = Handler(
//    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
//      String message = params["message"]?.first;
//      String colorHex = params["color_hex"]?.first;
//      String result = params["result"]?.first;
//      Color color = Color(0xFFFFFFFF);
//      if (colorHex != null && colorHex.length > 0) {
//        color = Color(ColorHelpers.fromHexString(colorHex));
//      }
//      return DemoSimpleComponent(message: message, color: color, result: result);
//    });
//
//var demoFunctionHandler = Handler(
//    type: HandlerType.function,
//    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
//      String message = params["message"]?.first;
//      showDialog(
//        context: context,
//        builder: (context) {
//          return AlertDialog(
//            title: Text(
//              "Hey Hey!",
//              style: TextStyle(
//                color: const Color(0xFF00D6F7),
//                fontFamily: "Lazer84",
//                fontSize: 22.0,
//              ),
//            ),
//            content: Text("$message"),
//            actions: <Widget>[
//              Padding(
//                padding: EdgeInsets.only(bottom: 8.0, right: 8.0),
//                child: FlatButton(
//                  onPressed: () {
//                    Navigator.of(context).pop(true);
//                  },
//                  child: Text("OK"),
//                ),
//              ),
//            ],
//          );
//        },
//      );
//    });
//
///// Handles deep links into the app
///// To test on Android:
/////
///// `adb shell am start -W -a android.intent.action.VIEW -d "fluro://deeplink?path=/message&mesage=fluro%20rocks%21%21" com.theyakka.fluro`
//var deepLinkHandler = Handler(
//    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
//      String colorHex = params["color_hex"]?.first;
//      String result = params["result"]?.first;
//      Color color = Color(0xFFFFFFFF);
//      if (colorHex != null && colorHex.length > 0) {
//        color = Color(ColorHelpers.fromHexString(colorHex));
//      }
//      return DemoSimpleComponent(
//          message: "DEEEEEP LINK!!!", color: color, result: result);
//    });
