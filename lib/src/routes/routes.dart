import 'dart:io';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../extension/navigator_ext.dart';
import 'route_handlers.dart';

class Routes {
  static const String root = "/";

  //tools page
  static const String toolspage_webview_page = '/toolspage/webview_page';
  static const String toolspage_qrcode_page = '/toolspage/qrcode_page';

  //wallet
  static const String wallet_create = '/wallet/create';
  static const String wallet_import = '/wallet/import';
  static const String wallet_account_detail = '/wallet/account/detail';
  static const String wallet_account_send_transaction =
      '/wallet/account/send_transaction';
  static const String wallet_transfer_token_confirm =
      '/wallet/account/confirm_transfer';
  static const String wallet_manager = '/wallet/manager';
  static const String wallet_setting = '/wallet/manager/setting';
  static const String wallet_setting_wallet_backup_notice =
      '/wallet/manager/setting/backup_notice';
  static const String wallet_backup_notice_for_creation =
      '/wallet/create/backup_notice';
  static const String wallet_show_resume_word =
      '/wallet/create/show_resume_word';
  static const String wallet_confirm_resume_word =
      '/wallet/create/confirm_resume_word';
  static const String confirm_success_papge = '/wallet/transfer/success_page';

  ///Exchange
  static const String exchange_assets_page = '/exchange/assets';
  static const String exchange_transfer_page = '/exchange/transfer';
  static const String exchange_deposit_confirm_page =
      '/exchange/deposit_confirm';
  static const String exchange_withdraw_confirm_page =
      '/exchange/withdraw_confirm';
  static const String exchange_transfer_success_page =
      '/exchange/transfer_success';

  //contribution
  static const String contribute_tasks_list = '/contribution/tasks';
  static const String contribute_done = '/contribution/done';
  static const String contribute_scan_signal =
      '/contribution/tasks/signal_scan';
  static const String contribute_add_poi = '/contribution/tasks/add_poi';
  static const String contribute_verify_poi = '/contribution/tasks/verify_poi';
  static const String contribute_add_nCov_poi =
      '/contribution/tasks/add_nCov_poi';
  static const String contribute_position_finish =
      '/contribution/tasks/position_finish';

  //map3node
  static const String map3node_product_list = '/map3node/product_list';
  static const String map3node_create_wallet = '/map3node/create_wallet';
  static const String map3node_create_contract_page = '/map3node/create_contract_page';
  static const String map3node_create_confirm_page = '/map3node/create_confirm_page';
  static const String map3node_edit_page = '/map3node/edit_page';
  static const String map3node_pre_edit_page = '/map3node/pre_edit_page';
  static const String map3node_formal_confirm_page = '/map3node/formal_confirm_page';

  static const String map3node_join_contract_page = '/map3node/join_contract_page';
  static const String map3node_send_confirm_page = '/map3node/send_confirm_page';
  static const String map3node_broadcast_success_page = '/map3node/broadcase_success_page';
  static const String map3node_contract_detail_page = '/map3node/contract_detail_page';
  static const String map3node_share_page = '/map3node/share_page';
  static const String map3node_introduction_page = '/map3node/pre_create_contract_page';
  static const String map3node_my_page = '/map3node/my_page';
  static const String map3node_list_page = '/map3node/list_page';
  static const String map3node_exit_page = '/map3node/exit_page';
  static const String map3node_collect_page = '/map3node/collect_page';
  static const String map3node_cancel_page = '/map3node/cancel_page';
  static const String map3node_divide_page = '/map3node/divide_page';
  static const String map3node_divide_add_page = '/map3node/divide_confirm_page';

  //atlas
  static const String atlas_create_node_page = '/atlas/atlas_create_node';
  static const String atlas_create_node_info_page = '/atlas/atlas_create_node_info';
  static const String atlas_create_node_confirm_page = '/atlas/atlas_create_node_confirm';
  static const String atlas_broadcast_success_page = '/atlas/atlas_broadcast_success';
  static const String atlas_detail_page = '/atlas/atlas_detail';
  static const String atlas_my_node_page = '/atlas/atlas_my_node';

  static String cachedEntryRouteName;

  static void popUntilCachedEntryRouteName<T extends Object>(
      BuildContext context,
      [T result]) {
    print("Routes.cachedEntryRouteName:${Routes.cachedEntryRouteName}");
    if (Routes.cachedEntryRouteName == null) {
      //back to root
      Navigator.of(context).popUntilRouteName(Routes.root, result);
    } else {
      print("Routes.cachedEntryRouteName:nulllllll, result:$result");
      Navigator.of(context)
          .popUntilRouteName(Routes.cachedEntryRouteName, result);

      Routes.cachedEntryRouteName = null;
    }
  }

  static void pushAndRemove(
      BuildContext context, Route newRoute, String rootName) {
    Navigator.of(context).pushAndRemoveUntil(
      newRoute,
      ModalRoute.withName(rootName),
    );
  }

  static void configureRoutes(Router router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
      return unknownPage();
    });

    //root
    router.define(root,
        handler: rootHandler, transitionType: TransitionType.fadeIn);

    //tools
    router.define(toolspage_webview_page,
        handler: toolsPageWebviewHandler,
        transitionType: pushNewPageTransitionType);
    router.define(toolspage_qrcode_page,
        handler: toolsPageQrcodeHandler,
        transitionType: pushNewPageTransitionType);

    //wallet
    router.define(wallet_create,
        handler: createWalletHandler,
        transitionType: pushNewPageTransitionType);
    router.define(wallet_import,
        handler: importWalletHandler,
        transitionType: pushNewPageTransitionType);
    router.define(wallet_account_detail,
        handler: walletAccountDetailHandler,
        transitionType: pushNewPageTransitionType);
    router.define(wallet_account_send_transaction,
        handler: walletAccountSendTransactionHandler,
        transitionType: pushNewPageTransitionType);
    router.define(wallet_transfer_token_confirm,
        handler: transferConfirmHandler,
        transitionType: pushNewPageTransitionType);
    router.define(wallet_manager,
        handler: managerWalletHandler,
        transitionType: pushNewPageTransitionType);
    router.define(wallet_setting,
        handler: settingWalletHandler,
        transitionType: pushNewPageTransitionType);
    router.define(wallet_setting_wallet_backup_notice,
        handler: settingBackupNoticeWalletHandler,
        transitionType: pushNewPageTransitionType);
    router.define(wallet_backup_notice_for_creation,
        handler: backUpMnemoicNoticeForCreation,
        transitionType: pushNewPageTransitionType);
    router.define(wallet_show_resume_word,
        handler: showResumeWordForCreation,
        transitionType: pushNewPageTransitionType);
    router.define(wallet_confirm_resume_word,
        handler: confirmResumeWordForCreation,
        transitionType: pushNewPageTransitionType);
    router.define(confirm_success_papge,
        handler: confirmSuccessHandler,
        transitionType: pushNewPageTransitionType);

    ///Exchange
    router.define(
      exchange_assets_page,
      handler: exchangeAssetsHandler,
      transitionType: pushNewPageTransitionType,
    );
    router.define(
      exchange_transfer_page,
      handler: exchangeTransferHandler,
      transitionType: pushNewPageTransitionType,
    );
    router.define(exchange_deposit_confirm_page,
        handler: exchangeDepositConfirmHandler,
        transitionType: pushNewPageTransitionType);

    router.define(exchange_withdraw_confirm_page,
        handler: exchangeWithdrawConfirmHandler,
        transitionType: pushNewPageTransitionType);

    router.define(
      exchange_transfer_success_page,
      handler: exchangeTransferSuccessHandler,
      transitionType: pushNewPageTransitionType,
    );

    //contribution
    router.define(contribute_tasks_list, handler: contributionTasksHandler, transitionType: pushNewPageTransitionType);
    router.define(
      contribute_done,
      handler: contributionDoneHandler,
      transitionType: pushNewPageTransitionType,
    );
    router.define(contribute_scan_signal,
        handler: contributionScanSignalHandler,
        transitionType: pushNewPageTransitionType);
    router.define(contribute_position_finish,
        handler: contributionPositionFinishHandler,
        transitionType: pushNewPageTransitionType);

    //map3node
    router.define(map3node_create_wallet,
        handler: map3NodeCreateWalletHandler, transitionType: pushNewPageTransitionType);
    router.define(
      map3node_create_contract_page,
      handler: map3NodeCreateContractHandler,
      transitionType: pushNewPageTransitionType,
    );
    router.define(
      map3node_create_confirm_page,
      handler: map3NodeCreateConfirmHandler,
      transitionType: pushNewPageTransitionType,
    );

    router.define(
      map3node_edit_page,
      handler: map3NodeEditHandler,
      transitionType: pushNewPageTransitionType,
    );

    router.define(
      map3node_pre_edit_page,
      handler: map3NodePreEditHandler,
      transitionType: pushNewPageTransitionType,
    );

    router.define(
      map3node_formal_confirm_page,
      handler: map3NodeFormalConfirmHandler,
      transitionType: pushNewPageTransitionType,
    );
    router.define(map3node_join_contract_page,
        handler: map3NodeJoinContractHandler, transitionType: pushNewPageTransitionType);
    router.define(map3node_broadcast_success_page,
        handler: map3NodeBroadcastSuccessHandler, transitionType: pushNewPageTransitionType);
    router.define(map3node_contract_detail_page,
        handler: map3NodeContractDetailHandler, transitionType: pushNewPageTransitionType);
    router.define(map3node_share_page, handler: map3NodeShareHandler, transitionType: pushNewPageTransitionType);

    router.define(
      map3node_introduction_page,
      handler: map3NodeIntroductionHandler,
      transitionType: pushNewPageTransitionType,
    );

    router.define(
      map3node_my_page,
      handler: map3NodeMyHandler,
      transitionType: pushNewPageTransitionType,
    );

    router.define(
      map3node_list_page,
      handler: map3NodeListHandler,
      transitionType: pushNewPageTransitionType,
    );

    router.define(
      map3node_exit_page,
      handler: map3NodeExitHandler,
      transitionType: pushNewPageTransitionType,
    );

    router.define(
      map3node_collect_page,
      handler: map3NodeCollectHandler,
      transitionType: pushNewPageTransitionType,
    );

    router.define(
      map3node_cancel_page,
      handler: map3NodeCancelHandler,
      transitionType: pushNewPageTransitionType,
    );

    router.define(
      map3node_divide_page,
      handler: map3NodeDivideHandler,
      transitionType: pushNewPageTransitionType,
    );

    router.define(
      map3node_divide_add_page,
      handler: map3NodeDivideAddHandler,
      transitionType: pushNewPageTransitionType,
    );

    ///Atlas
    router.define(
      atlas_my_node_page,
      handler: atlasMyNodeHandler,
      transitionType: pushNewPageTransitionType,
    );

    router.define(
      atlas_create_node_page,
      handler: atlasCreateNodeHandler,
      transitionType: pushNewPageTransitionType,
    );
    router.define(
      atlas_create_node_info_page,
      handler: atlasCreateNodeInfoHandler,
      transitionType: pushNewPageTransitionType,
    );
    router.define(
      atlas_create_node_confirm_page,
      handler: atlasCreateNodeConfirmHandler,
      transitionType: pushNewPageTransitionType,
    );
    router.define(
      atlas_broadcast_success_page,
      handler: atlasBroadcastSuccessHandler,
      transitionType: pushNewPageTransitionType,
    );
    router.define(
      atlas_detail_page,
      handler: atlasDetailHandler,
      transitionType: pushNewPageTransitionType,
    );
  }

  static TransitionType get pushNewPageTransitionType {
    if (Platform.isIOS) {
      return TransitionType.cupertino;
    } else {
      return TransitionType.inFromRight;
    }
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
    } else if (routeSettings.arguments == null) {
      settingsToUse = routeSettings.copyWith(arguments: Map());
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
