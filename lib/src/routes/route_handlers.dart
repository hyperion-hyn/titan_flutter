import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/components/root_page_control_component/root_page_control_component.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/pages/contribution/add_poi/position_finish_page.dart';
import 'package:titan/src/pages/node/map3page/map3_node_contract_detail_page.dart';
import 'package:titan/src/pages/node/map3page/map3_node_broadcase_success_page.dart';
import 'package:titan/src/pages/node/map3page/map3_node_create_contract_page.dart';
import 'package:titan/src/pages/node/map3page/map3_node_create_wallet_page.dart';
import 'package:titan/src/pages/node/map3page/map3_node_join_contract_page.dart';
import 'package:titan/src/pages/node/map3page/map3_node_product_page.dart';
import 'package:titan/src/pages/node/map3page/map3_node_send_confirm_page.dart';
import 'package:titan/src/pages/node/map3page/map3_node_share_page.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/wallet/confirm_success_page.dart';
import 'package:titan/src/pages/wallet/wallet_backup_notice_page.dart';
import 'package:titan/src/pages/wallet/wallet_confirm_resume_word_page.dart';
import 'package:titan/src/pages/wallet/wallet_create_backup_notice_page.dart';
import 'package:titan/src/pages/wallet/wallet_setting.dart';
import 'package:titan/src/pages/wallet/wallet_show_resume_word_page.dart';
import 'package:titan/src/pages/webview/inappwebview.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
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
import 'fluro_convert_utils.dart';

var rootHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return RootPageControlComponent(key: Keys.rootKey);
});

//wallet
var createWalletHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return CreateAccountPage();
});

var importWalletHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return ImportAccountPage();
});

void _cacheEntryRouteName(params) {
  var url = params["entryRouteName"]?.first;
  if (url != null && url != '') {
    url = Uri.decodeComponent(url);
    Routes.cachedEntryRouteName = url;
  }
}

var toolsPageWebviewHandler = Handler(handlerFunc: (context, params) {
  return InAppWebViewContainer(
      initUrl: FluroConvertUtils.fluroCnParamsDecode(params['initUrl']?.first),
      title: FluroConvertUtils.fluroCnParamsDecode(params['title']?.first));
});

var walletAccountDetailHandler = Handler(handlerFunc: (context, params) {
  return ShowAccountPage(params['coinVo']?.first);
});

var walletAccountSendTransactionHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return WalletSendPage(params['coinVo']?.first, params['toAddress']?.first);
});

var transferConfirmHandler = Handler(handlerFunc: (context, params) {
  return WalletSendConfirmPage(
      params['coinVo']?.first, '${params['transferAmount']?.first ?? 0}', params['receiverAddress']?.first);
});

var managerWalletHandler = Handler(
    handlerFunc: (context, params) =>
        BlocProvider<WalletManagerBloc>(create: (context) => WalletManagerBloc(), child: WalletManagerPage()));

var settingWalletHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  Wallet wallet = Wallet.fromJson(FluroConvertUtils.string2map(params['walletStr']?.first));
  return WalletSettingPage(wallet);
});

var settingBackupNoticeWalletHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  Wallet wallet = Wallet.fromJson(FluroConvertUtils.string2map(params['walletStr']?.first));
  return WalletBackupNoticePage(wallet);
});

var backUpMnemoicNoticeForCreation = Handler(handlerFunc: (context, params) {
  return CreateWalletBackupNoticePage(params['walletName']?.first, params['password']?.first);
});

var showResumeWordForCreation = Handler(handlerFunc: (context, params) {
  return ShowResumeWordPage(params['walletName']?.first, params['password']?.first);
});

var confirmResumeWordForCreation = Handler(handlerFunc: (context, params) {
  return ConfirmResumeWordPage(params['mnemonic']?.first, params['walletName']?.first, params['password']?.first);
});

var confirmSuccessHandler = Handler(handlerFunc: (context, params) {
  return ConfirmSuccessPage();
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

var contributionPositionFinishHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return FinishAddPositionPage(params['pageType']?.first);
});

var map3NodeProductListHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return Map3NodeProductPage();
});

var map3NodeCreateWalletHandler = Handler(handlerFunc: (context, params) {
  return Map3NodeCreateWalletPage();
});

var map3NodeCreateContractHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return Map3NodeCreateContractPage(params['contractId']?.first);
});

var map3NodeJoinContractHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  print("[dd] Routes.cachedEntryRouteName:${Routes.cachedEntryRouteName}");

  return Map3NodeJoinContractPage(params['contractId']?.first);
});

var map3NodeSendConfirmHandler = Handler(handlerFunc: (context, params) {
  ContractNodeItem contractNodeItem =
      ContractNodeItem.fromJson(FluroConvertUtils.string2map(params['contractNodeItem']?.first));
  var transferAmount = params['transferAmount']?.first ?? '0';

  return Map3NodeSendConfirmPage(
    params['coinVo']?.first ?? '0',
    contractNodeItem,
    Decimal.parse(transferAmount),
    params['receiverAddress']?.first ?? '0',
    params['pageType']?.first,
    params['contractId']?.first,
    provider: params['provider']?.first ?? "",
    region: params['region']?.first ?? "",
  );
});

var map3NodeBroadcaseSuccessHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  ContractNodeItem contractNodeItem;
  var item = params['contractNodeItem']?.first;
  if(item != null ) {
    contractNodeItem =
        ContractNodeItem.fromJson(FluroConvertUtils.string2map(item));
  }
  return Map3NodeBroadcaseSuccessPage(
    params['pageType']?.first,
    contractNodeItem: contractNodeItem,
  );
});

var map3NodeContractDetailHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);

  return Map3NodeContractDetailPage(int.parse(params['contractId']?.first));
});

var map3NodeShareHandler = Handler(handlerFunc: (context, params) {
  ContractNodeItem contractNodeItem =
      ContractNodeItem.fromJson(FluroConvertUtils.string2map(params['contractNodeItem']?.first));
  return Map3NodeSharePage(contractNodeItem);
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
