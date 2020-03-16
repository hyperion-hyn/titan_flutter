import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/components/root_page_control_component/root_page_control_component.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/pages/wallet/wallet_confirm_resume_word_page.dart';
import 'package:titan/src/pages/wallet/wallet_create_backup_notice_page.dart';
import 'package:titan/src/pages/wallet/wallet_show_resume_word_page.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/pages/contribution/contribution_finish_page.dart';
import 'package:titan/src/pages/contribution/contribution_tasks_page.dart';
import 'package:titan/src/pages/contribution/signal_scan/scan_signal_contribution_page.dart';
import 'package:titan/src/pages/wallet/wallet_create_new_account_page.dart';
import 'package:titan/src/pages/wallet/wallet_import_account_page.dart';
import 'package:titan/src/pages/wallet/wallet_manager/bloc/bloc.dart';
import 'package:titan/src/pages/wallet/wallet_manager/wallet_manager_page.dart';
import 'package:titan/src/pages/wallet/wallet_send_confirm_page.dart';
import 'package:titan/src/pages/wallet/wallet_send_page.dart';
import 'package:titan/src/pages/wallet/wallet_show_account_widget.dart';

import '../config/consts.dart';

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

var backUpMnemoicNoticeForCreation = Handler(handlerFunc: (context, params) {
  return CreateWalletBackupNoticePage(params['walletName']?.first,params['password']?.first);
});

var showResumeWordForCreation = Handler(handlerFunc: (context, params) {
  return ShowResumeWordPage(params['walletName']?.first,params['password']?.first);
});

var confirmResumeWordForCreation = Handler(handlerFunc: (context, params) {
  return ConfirmResumeWordPage(params['mnemonic']?.first,params['walletName']?.first,params['password']?.first);
});

//contribution
var contributionTasksHandler = Handler(handlerFunc: (context, params) {
  return ContributionTasksPage();
});

var contributionDoneHandler = Handler(handlerFunc: (context, params) {
  return ContributionFinishUploadPage(backRouteName: params['backRouteName']?.first);
});

var contributionScanSignalHandler = Handler(handlerFunc: (context, params) {
  return ScanSignalContributionPage(latLng: params['latLng']?.first);
});

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
