import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../extension/navigator_ext.dart';
import 'route_handlers.dart';

class Routes {
  static const String root = "/";

  static const String wallet_create = '/wallet/create';
  static const String wallet_import = '/wallet/import';
  static const String wallet_account_detail = '/wallet/account/detail';
  static const String wallet_account_send_transaction = '/wallet/account/send_transaction';
  static const String wallet_transfer_token_confirm = '/wallet/account/confirm_transfer';
  static const String wallet_manager = '/wallet/manager';

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
      return Scaffold(
          appBar: AppBar(
            title: Text('404'),
          ),
          body: Center(child: Text('page not found')));
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
  }
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
