import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/components/root_page_control_component/root_page_control_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_create_info_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_create_node_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_detail_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_my_node_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/burn_history_page.dart';
import 'package:titan/src/pages/atlas_map/entity/create_atlas_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/create_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_broadcast_success_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_cancel_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_reward_tabs_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_create_confirm_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_create_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_create_wallet_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_detail_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_divide_add_page_pending.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_divide_page_pending.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_edit_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_exit_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_introduction_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_join_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_list_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_my_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_pre_edit_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_share_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_collect_history_page.dart';
import 'package:titan/src/pages/contribution/add_poi/position_finish_page.dart';
import 'package:titan/src/pages/market/exchange_assets_page.dart';
import 'package:titan/src/pages/market/transfer/exchange_qrcode_deposit_page.dart';
import 'package:titan/src/pages/market/transfer/exchange_transfer_page.dart';
import 'package:titan/src/pages/market/transfer/exchange_transfer_success_page.dart';
import 'package:titan/src/pages/market/transfer/exchange_withdraw_confirm_page.dart';
import 'package:titan/src/pages/mine/qr_code_page.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/red_pocket/red_pocket_page.dart';
import 'package:titan/src/pages/wallet/confirm_success_page.dart';
import 'package:titan/src/pages/wallet/wallet_new_page/wallet_create_import_account_page_v2.dart';
import 'package:titan/src/pages/wallet/wallet_new_page/wallet_backup_notice_page_v2.dart';
import 'package:titan/src/pages/wallet/wallet_new_page/wallet_setting_page_v2.dart';
import 'package:titan/src/pages/wallet/wallet_setting.dart';
import 'package:titan/src/pages/wallet/wallet_show_account_hb_widget.dart';
import 'package:titan/src/pages/wallet/wallet_show_resume_word_page.dart';
import 'package:titan/src/pages/webview/inappwebview.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/pages/contribution/contribution_finish_page.dart';
import 'package:titan/src/pages/contribution/contribution_tasks_page.dart';
import 'package:titan/src/pages/contribution/signal_scan/scan_signal_contribution_page.dart';
import 'package:titan/src/pages/wallet/wallet_import_account_page.dart';
import 'package:titan/src/pages/wallet/wallet_manager/bloc/bloc.dart';
import 'package:titan/src/pages/wallet/wallet_manager/wallet_manager_page.dart';
import 'package:titan/src/pages/wallet/wallet_send_confirm_page.dart';
import 'package:titan/src/pages/wallet/wallet_send_page_v2.dart';
import 'package:titan/src/pages/wallet/wallet_show_account_widget.dart';
import 'package:titan/src/pages/wallet/wallet_show_account_hyn_widget.dart';
import 'package:titan/src/components/wallet/vo/coin_view_vo.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';

import '../config/consts.dart';
import 'fluro_convert_utils.dart';

var rootHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return RootPageControlComponent(key: Keys.rootKey);
});

//wallet
var createWalletHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  //isCreate 1、创建钱包 2、导入钱包
  return WalletCreateAccountPageV2(params['isCreate']?.first == "1");
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
  String webUrl =
      FluroConvertUtils.fluroCnParamsDecode(params['initUrl']?.first);
  var language =
      SettingInheritedModel.of(Keys.rootKey.currentContext).netLanguageCode;
  if (!webUrl.contains("?")) {
    webUrl = webUrl + "?lang=$language";
  } else {
    webUrl = webUrl + "&lang=$language";
  }
  return InAppWebViewContainer(
      initUrl: webUrl,
      title: FluroConvertUtils.fluroCnParamsDecode(params['title']?.first));
});

var toolsPageQrcodeHandler = Handler(handlerFunc: (context, params) {
  return QrCodePage(params['qrCodeStr']?.first);
});

var walletAccountDetailHandler = Handler(handlerFunc: (context, params) {
  var coinVo =
      CoinViewVo.fromJson(FluroConvertUtils.string2map(params['coinVo']?.first));
  if (coinVo.coinType == CoinType.HYN_ATLAS) {
    return ShowAccountHynPage(coinVo);
  }else if(coinVo.coinType == CoinType.HB_HT){
    return ShowAccountHbPage(coinVo);
  }else{
    return ShowAccountPage(coinVo);
  }
});

var walletAccountSendTransactionHandler =
    Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return WalletSendPageV2(params['coinVo']?.first, params['toAddress']?.first);
});

var transferConfirmHandler = Handler(handlerFunc: (context, params) {
  return WalletSendConfirmPage(
      params['coinVo']?.first,
      '${params['transferAmount']?.first ?? 0}',
      params['receiverAddress']?.first);
});

var managerWalletHandler = Handler(
    handlerFunc: (context, params) => BlocProvider<WalletManagerBloc>(
        create: (context) => WalletManagerBloc(),
        child: WalletManagerPage(
          tips: FluroConvertUtils.fluroCnParamsDecode(params['tips']?.first),
        )));

var settingWalletHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  Wallet wallet =
      Wallet.fromJson(FluroConvertUtils.string2map(params['walletStr']?.first));
  print("!!!!!444 ${wallet.walletExpandInfoEntity.toJson()}");
  return WalletSettingPageV2(wallet);
});

var settingBackupNoticeWalletHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  Wallet wallet =
      Wallet.fromJson(FluroConvertUtils.string2map(params['walletStr']?.first));
  return WalletBackupNoticePageV2(wallet);
});

var confirmSuccessHandler = Handler(handlerFunc: (context, params) {
  var msg = params['msg']?.first != null
      ? FluroConvertUtils.fluroCnParamsDecode(params['msg']?.first)
      : null;
  return ConfirmSuccessPage(msg: msg);
});

// rp
var redPocketHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return RedPocketPage();
});

///Exchange
var exchangeAssetsHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return ExchangeAssetsPage();
});

var exchangeTransferHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return ExchangeTransferPage(params['coinType']?.first);
});

var exchangeQrcodeDepositHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return ExchangeQrcodeDepositPage(params['coinType']?.first);
});


var exchangeDepositConfirmHandler = Handler(handlerFunc: (context, params) {
  return WalletSendConfirmPage(
      params['coinVo']?.first, '${params['transferAmount']?.first ?? 0}', params['exchangeAddress']?.first);
});

var exchangeWithdrawConfirmHandler = Handler(handlerFunc: (context, params) {
  return ExchangeWithdrawConfirmPage(
    params['coinVo']?.first,
    '${params['amount']?.first ?? 0}',
    params['withdrawFeeByGas']?.first,
  );
});

var exchangeTransferSuccessHandler = Handler(handlerFunc: (context, params) {
  return ExchangeTransferSuccessPage();
});

//contribution
var contributionTasksHandler = Handler(handlerFunc: (context, params) {
  return ContributionTasksPage();
});

var contributionDoneHandler = Handler(handlerFunc: (context, params) {
  return ContributionFinishUploadPage(
      backRouteName: params['backRouteName']?.first);
});

var contributionScanSignalHandler = Handler(handlerFunc: (context, params) {
  return ScanSignalContributionPage(latLng: params['latLng']?.first);
});

var contributionPositionFinishHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return FinishAddPositionPage(params['pageType']?.first);
});

var map3NodeCreateWalletHandler = Handler(handlerFunc: (context, params) {
  return Map3NodeCreateWalletPage(params['pageType']?.first);
});

var map3NodeCreateContractHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return Map3NodeCreatePage(params['contractId']?.first);
});

var map3NodeCreateConfirmHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);

  var item = params['entity']?.first;
  CreateMap3Payload entity;
  if (item != null) {
    entity = CreateMap3Payload.fromJson(FluroConvertUtils.string2map(item));
  }
  return Map3NodeCreateConfirmPage(
    payload: entity,
  );
});

var map3NodeEditHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);

  var item = params['entity']?.first;
  Map3InfoEntity entity;
  if (item != null) {
    entity = Map3InfoEntity.fromJson(FluroConvertUtils.string2map(item));
  }

  return Map3NodeEditPage(
    map3InfoEntity: entity,
  );
});

var map3NodePreEditHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  Map3InfoEntity map3infoEntity = Map3InfoEntity.fromJson(
      FluroConvertUtils.string2map(params['info']?.first));
  return Map3NodePreEditPage(
    map3infoEntity: map3infoEntity,
  );
});

var map3NodeJoinContractHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  Map3InfoEntity map3infoEntity = Map3InfoEntity.fromJson(
      FluroConvertUtils.string2map(params['entityInfo']?.first));
  return Map3NodeJoinPage(
    map3infoEntity,
  );
});

var map3NodeBroadcastSuccessHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  Map3InfoEntity map3infoEntity;
  var item = params['info']?.first;
  if (item != null) {
    map3infoEntity =
        Map3InfoEntity.fromJson(FluroConvertUtils.string2map(item));
  }

  var actionEvent = params['actionEvent']?.first;

  return Map3NodeBroadcastSuccessPage(
    actionEvent: enumActionEventFromString(actionEvent),
    infoEntity: map3infoEntity,
  );
});

var map3NodeContractDetailHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);

  Map3InfoEntity entity = Map3InfoEntity.fromJson(
      FluroConvertUtils.string2map(params['info']?.first));

  return Map3NodeDetailPage(entity);
});

var map3NodeShareHandler = Handler(handlerFunc: (context, params) {
  Map3InfoEntity map3infoEntity = Map3InfoEntity.fromJson(
      FluroConvertUtils.string2map(params['info']?.first));
  return Map3NodeSharePage(map3infoEntity);
});

var map3AtlasNodeShareHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);

  Map3InfoEntity entity = Map3InfoEntity.fromJson(
      FluroConvertUtils.string2map(params['info']?.first));

  return Map3NodeDetailPage(entity);
});

var map3NodeIntroductionHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return Map3NodeIntroductionPage();
});

var map3NodeBurnHistoryHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return BurnHistoryPage();
});


var map3NodeMyHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return Map3NodeMyPage();
});

var map3NodeMyHandlerReward = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return Map3NodeCollectHistoryPage();
});

var map3NodeMyHandlerRewardNew = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return Map3NodeRewardTabsPage();
});

var map3NodeListHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);

  print('params:$params');
  var title = params['title']?.first;
  var index = int.parse(params['active']?.first);
  var active = MyContractType.values[index];
  var model = MyContractModel(title, active);
  return Map3NodeListPage(model);
});

var map3NodeExitHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  Map3InfoEntity map3infoEntity = Map3InfoEntity.fromJson(
      FluroConvertUtils.string2map(params['info']?.first));
  return Map3NodeExitPage(
    map3infoEntity: map3infoEntity,
  );
});

var map3NodeCancelHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  Map3InfoEntity map3infoEntity = Map3InfoEntity.fromJson(
      FluroConvertUtils.string2map(params['info']?.first));
  return Map3NodeCancelPage(
    map3infoEntity: map3infoEntity,
  );
});

var map3NodeDivideHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return Map3NodeDividePage();
});

var map3NodeDivideAddHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return Map3NodeDivideAddPage();
});

//atlas
var atlasMyNodeHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return AtlasMyNodePage();
});

var atlasCreateNodeHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return AtlasCreateNodePage();
});

var atlasCreateNodeInfoHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  CreateAtlasPayload _createAtlasPayload = CreateAtlasPayload.fromJson(
    FluroConvertUtils.string2map(params['createAtlasPayload']?.first),
  );
  var _selectedMap3NodeName = FluroConvertUtils.fluroCnParamsDecode(
    params['selectedMap3NodeName']?.first,
  );

  return AtlasCreateInfoPage(
    _createAtlasPayload,
    _selectedMap3NodeName,
  );
});

var atlasDetailHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  var atlasNodeId = FluroConvertUtils.fluroCnParamsDecode(
    params['atlasNodeId']?.first,
  );
  var atlasNodeAddress = FluroConvertUtils.fluroCnParamsDecode(
    params['atlasNodeAddress']?.first,
  );
  return AtlasDetailPage(atlasNodeId, atlasNodeAddress);
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
