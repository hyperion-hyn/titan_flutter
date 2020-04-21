import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../extension/navigator_ext.dart';
import 'route_handlers.dart';

class Routes {
  static const String root = "/";

  //tools page
  static const String toolspage_webview_page = '/toolspage/webview_page';

  //wallet
  static const String wallet_create = '/wallet/create';
  static const String wallet_import = '/wallet/import';
  static const String wallet_account_detail = '/wallet/account/detail';
  static const String wallet_account_send_transaction = '/wallet/account/send_transaction';
  static const String wallet_transfer_token_confirm = '/wallet/account/confirm_transfer';
  static const String wallet_manager = '/wallet/manager';
  static const String wallet_setting = '/wallet/manager/setting';
  static const String wallet_setting_wallet_backup_notice = '/wallet/manager/setting/backup_notice';
  static const String wallet_backup_notice_for_creation = '/wallet/create/backup_notice';
  static const String wallet_show_resume_word = '/wallet/create/show_resume_word';
  static const String wallet_confirm_resume_word = '/wallet/create/confirm_resume_word';
  static const String confirm_success_papge = '/wallet/transfer/success_page';

  //contribution
  static const String contribute_tasks_list = '/contribution/tasks';
  static const String contribute_done = '/contribution/done';
  static const String contribute_scan_signal = '/contribution/tasks/signal_scan';
  static const String contribute_add_poi = '/contribution/tasks/add_poi';
  static const String contribute_verify_poi = '/contribution/tasks/verify_poi';
  static const String contribute_add_nCov_poi = '/contribution/tasks/add_nCov_poi';
  static const String contribute_position_finish = '/contribution/tasks/position_finish';

  //map3node
  static const String map3node_product_list = '/map3node/product_list';
  static const String map3node_create_wallet = '/map3node/create_wallet';
  static const String map3node_create_contract_page = '/map3node/create_contract_page';
  static const String map3node_join_contract_page = '/map3node/join_contract_page';
  static const String map3node_send_confirm_page = '/map3node/send_confirm_page';
  static const String map3node_broadcase_success_page = '/map3node/broadcase_success_page';
  static const String map3node_contract_detail_page = '/map3node/contract_detail_page';
  static const String map3node_share_page = '/map3node/share_page';

  static String cachedEntryRouteName;

  static void popUntilCachedEntryRouteName<T extends Object>(BuildContext context, [T result]) {
    if (Routes.cachedEntryRouteName == null) {
      //back to root
      Navigator.of(context).popUntilRouteName(Routes.root, result);
    } else {
      Navigator.of(context).popUntilRouteName(Routes.cachedEntryRouteName, result);
      Routes.cachedEntryRouteName = null;
    }
  }

  static void pushAndRemove(BuildContext context, Route newRoute, String rootName) {
    Navigator.of(context).pushAndRemoveUntil(
      newRoute,
      ModalRoute.withName(rootName),
    );
  }

  static void configureRoutes(Router router) {
    router.notFoundHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
      return unknownPage();
    });

    //root
    router.define(root, handler: rootHandler, transitionType: TransitionType.fadeIn);

    //tools
    router.define(toolspage_webview_page, handler: toolsPageWebviewHandler, transitionType: TransitionType.inFromRight);

    //wallet
    router.define(wallet_create, handler: createWalletHandler, transitionType: TransitionType.inFromRight);
    router.define(wallet_import, handler: importWalletHandler, transitionType: TransitionType.inFromRight);
    router.define(wallet_account_detail,
        handler: walletAccountDetailHandler, transitionType: TransitionType.inFromRight);
    router.define(wallet_account_send_transaction,
        handler: walletAccountSendTransactionHandler, transitionType: TransitionType.inFromRight);
    router.define(wallet_transfer_token_confirm,
        handler: transferConfirmHandler, transitionType: TransitionType.inFromRight);
    router.define(wallet_manager, handler: managerWalletHandler, transitionType: TransitionType.inFromRight);
    router.define(wallet_setting, handler: settingWalletHandler, transitionType: TransitionType.inFromRight);
    router.define(wallet_setting_wallet_backup_notice,
        handler: settingBackupNoticeWalletHandler, transitionType: TransitionType.inFromRight);
    router.define(wallet_backup_notice_for_creation,
        handler: backUpMnemoicNoticeForCreation, transitionType: TransitionType.inFromRight);
    router.define(wallet_show_resume_word,
        handler: showResumeWordForCreation, transitionType: TransitionType.inFromRight);
    router.define(wallet_confirm_resume_word,
        handler: confirmResumeWordForCreation, transitionType: TransitionType.inFromRight);
    router.define(confirm_success_papge, handler: confirmSuccessHandler, transitionType: TransitionType.inFromRight);

    //contribution
    router.define(contribute_tasks_list, handler: contributionTasksHandler, transitionType: TransitionType.inFromRight);
    router.define(contribute_done, handler: contributionDoneHandler, transitionType: TransitionType.inFromRight);
    router.define(contribute_scan_signal,
        handler: contributionScanSignalHandler, transitionType: TransitionType.inFromRight);
    router.define(contribute_position_finish,
        handler: contributionPositionFinishHandler, transitionType: TransitionType.inFromRight);

    //map3node
    router.define(map3node_product_list,
        handler: map3NodeProductListHandler, transitionType: TransitionType.inFromRight);
    router.define(map3node_create_wallet,
        handler: map3NodeCreateWalletHandler, transitionType: TransitionType.inFromRight);
    router.define(map3node_create_contract_page,
        handler: map3NodeCreateContractHandler, transitionType: TransitionType.inFromRight);
    router.define(map3node_join_contract_page,
        handler: map3NodeJoinContractHandler, transitionType: TransitionType.inFromRight);
    router.define(map3node_send_confirm_page,
        handler: map3NodeSendConfirmHandler, transitionType: TransitionType.inFromRight);
    router.define(map3node_broadcase_success_page,
        handler: map3NodeBroadcaseSuccessHandler, transitionType: TransitionType.inFromRight);
    router.define(map3node_contract_detail_page,
        handler: map3NodeContractDetailHandler, transitionType: TransitionType.inFromRight);
    router.define(map3node_share_page, handler: map3NodeShareHandler, transitionType: TransitionType.inFromRight);
  }

  static Widget unknownPage() => Scaffold(
      appBar: AppBar(
        title: Text('404'),
      ),
      body: Center(child: Text('page not found')));
}

class MyRouter extends Router {
  @override
  RouteMatch matchRoute(BuildContext buildContext, String path,
      {RouteSettings routeSettings,
      TransitionType transitionType,
      Duration transitionDuration = const Duration(milliseconds: 250),
      transitionsBuilder}) {
    RouteSettings settingsToUse = routeSettings;
    if (routeSettings?.arguments == null) {
      if (routeSettings == null) {
        settingsToUse = RouteSettings(name: path, arguments: Map());
      } else {
        settingsToUse = routeSettings.copyWith(arguments: Map());
      }
    }
    return super.matchRoute(
      buildContext,
      path,
      routeSettings: settingsToUse,
      transitionType: transitionType,
      transitionDuration: transitionDuration,
      transitionsBuilder: transitionsBuilder,
    );
  }
}
