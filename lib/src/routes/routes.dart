import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../extension/navigator_ext.dart';
import 'route_handlers.dart';

class Routes {
  static const String root = "/";

  //wallet
  static const String wallet_create = '/wallet/create';
  static const String wallet_import = '/wallet/import';
  static const String wallet_account_detail = '/wallet/account/detail';
  static const String wallet_account_send_transaction = '/wallet/account/send_transaction';
  static const String wallet_transfer_token_confirm = '/wallet/account/confirm_transfer';
  static const String wallet_manager = '/wallet/manager';
  static const String wallet_backup_notice_for_creation = 'wallet/create/backup_notice';
  static const String wallet_show_resume_word = 'wallet/create/show_resume_word';
  static const String wallet_confirm_resume_word = 'wallet/create/confirm_resume_word';

  //contribution
  static const String contribute_tasks_list = '/contribution/tasks';
  static const String contribute_done = '/contribution/done';
  static const String contribute_scan_signal = '/contribution/tasks/signal_scan';
  static const String contribute_add_poi = '/contribution/tasks/add_poi';
  static const String contribute_verify_poi = '/contribution/tasks/verify_poi';
  static const String contribute_add_nCov_poi = '/contribution/tasks/add_nCov_poi';

  static String createOrImportWalletEntryRouteName;

  static void popUntilCreateOrImportWalletEntryRoute<T extends Object>(BuildContext context, [T result]) {
    if (Routes.createOrImportWalletEntryRouteName == null) {
      //back to root
      Navigator.of(context).popUntilRouteName(Routes.root, result);
    } else {
      Navigator.of(context).popUntilRouteName(Routes.createOrImportWalletEntryRouteName, result);
      Routes.createOrImportWalletEntryRouteName = null;
    }
  }

  static void configureRoutes(Router router) {
    router.notFoundHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
      return unknownPage();
    });

    //home
    router.define(root, handler: rootHandler, transitionType: TransitionType.fadeIn);

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
    router.define(wallet_backup_notice_for_creation, handler: backUpMnemoicNoticeForCreation, transitionType: TransitionType.inFromRight);
    router.define(wallet_show_resume_word, handler: showResumeWordForCreation, transitionType: TransitionType.inFromRight);
    router.define(wallet_confirm_resume_word, handler: confirmResumeWordForCreation, transitionType: TransitionType.inFromRight);

    //contribution
    router.define(contribute_tasks_list, handler: contributionTasksHandler, transitionType: TransitionType.inFromRight);
    router.define(contribute_done, handler: contributionDoneHandler, transitionType: TransitionType.inFromRight);
    router.define(contribute_scan_signal, handler: contributionScanSignalHandler, transitionType: TransitionType.inFromRight);
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
    if (routeSettings == null) {
      settingsToUse = RouteSettings(name: path, arguments: Map());
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
