import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:titan/src/components/root_page_control_component/root_page_control_component.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_create_confirm_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_create_info_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_create_node_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_broadcast_success_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_detail_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_my_node_page.dart';
import 'package:titan/src/pages/atlas_map/entity/create_atlas_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/create_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_broadcast_success_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_cancel_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_collect_page_deprecated.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_reward_tabs_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_create_confirm_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_create_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_create_wallet_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_detail_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_divide_add_page_pending.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_divide_page_pending.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_edit_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_exit_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_formal_confirm_page_deprecated.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_introduction_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_join_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_list_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_my_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_pre_edit_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_share_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_collect_history_page.dart';
import 'package:titan/src/pages/contribution/add_poi/position_finish_page.dart';
import 'package:titan/src/pages/market/exchange_assets_page.dart';
import 'package:titan/src/pages/market/transfer/exchange_deposit_confirm_page.dart';
import 'package:titan/src/pages/market/transfer/exchange_transfer_page.dart';
import 'package:titan/src/pages/market/transfer/exchange_transfer_success_page.dart';
import 'package:titan/src/pages/market/transfer/exchange_withdraw_confirm_page.dart';
import 'package:titan/src/pages/mine/qr_code_page.dart';
import 'package:titan/src/pages/node/map3page/map3_node_broadcase_success_page.dart';
import 'package:titan/src/pages/node/map3page/map3_node_contract_detail_page_v8.dart';
import 'package:titan/src/pages/node/map3page/my_map3_contracts_page_v8.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/wallet/confirm_success_page.dart';
import 'package:titan/src/pages/wallet/wallet_backup_notice_page.dart';
import 'package:titan/src/pages/wallet/wallet_confirm_resume_word_page.dart';
import 'package:titan/src/pages/wallet/wallet_create_backup_notice_page.dart';
import 'package:titan/src/pages/wallet/wallet_setting.dart';
import 'package:titan/src/pages/wallet/wallet_show_resume_word_page.dart';
import 'package:titan/src/pages/webview/inappwebview.dart';
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
import 'package:titan/src/pages/wallet/wallet_show_account_hyn_widget.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';

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

var toolsPageQrcodeHandler = Handler(handlerFunc: (context, params) {
  return QrCodePage(params['qrCodeStr']?.first);
});

var walletAccountDetailHandler = Handler(handlerFunc: (context, params) {
  var coinVo = CoinVo.fromJson(FluroConvertUtils.string2map(params['coinVo']?.first));
  if(coinVo.coinType == CoinType.HYN_ATLAS){
    return ShowAccountHynPage(coinVo);
  }else{
    return ShowAccountPage(coinVo);
  }
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
    handlerFunc: (context, params) => BlocProvider<WalletManagerBloc>(
        create: (context) => WalletManagerBloc(),
        child: WalletManagerPage(
          tips: FluroConvertUtils.fluroCnParamsDecode(params['tips']?.first),
        )));

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
  var walletName = params['walletName']?.first != null
      ? FluroConvertUtils.fluroCnParamsDecode(params['walletName']?.first)
      : 'MyWallet';
  return CreateWalletBackupNoticePage(walletName, params['password']?.first);
});

var showResumeWordForCreation = Handler(handlerFunc: (context, params) {
  var walletName = params['walletName']?.first != null
      ? FluroConvertUtils.fluroCnParamsDecode(params['walletName']?.first)
      : 'MyWallet';
  return ShowResumeWordPage(walletName, params['password']?.first);
});

var confirmResumeWordForCreation = Handler(handlerFunc: (context, params) {
  return ConfirmResumeWordPage(params['mnemonic']?.first,
      FluroConvertUtils.fluroCnParamsDecode(params['walletName']?.first), params['password']?.first);
});

var confirmSuccessHandler = Handler(handlerFunc: (context, params) {
  var msg = params['msg']?.first != null ? FluroConvertUtils.fluroCnParamsDecode(params['msg']?.first) : null;
  return ConfirmSuccessPage(msg: msg);
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

var exchangeDepositConfirmHandler = Handler(handlerFunc: (context, params) {
  return ExchangeDepositConfirmPage(
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
  return ContributionFinishUploadPage(backRouteName: params['backRouteName']?.first);
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
  Map3InfoEntity map3infoEntity = Map3InfoEntity.fromJson(FluroConvertUtils.string2map(params['info']?.first));
  return Map3NodePreEditPage(
    map3infoEntity: map3infoEntity,
  );
});

var map3NodeFormalConfirmHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);

  var index = int.parse(params['actionEvent']?.first);
  var actionEvent = Map3NodeActionEvent.values[index];
  return Map3NodeFormalConfirmPage(
    actionEvent: actionEvent,
  );
});

var map3NodeJoinContractHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  Map3InfoEntity map3infoEntity = Map3InfoEntity.fromJson(FluroConvertUtils.string2map(params['entityInfo']?.first));
  return Map3NodeJoinPage(
    map3infoEntity,
  );
});

var map3NodeBroadcastSuccessHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  Map3InfoEntity map3infoEntity;
  var item = params['info']?.first;
  if (item != null) {
    map3infoEntity = Map3InfoEntity.fromJson(FluroConvertUtils.string2map(item));
  }

  var actionEvent = params['actionEvent']?.first;

  return Map3NodeBroadcastSuccessPage(
    actionEvent: enumActionEventFromString(actionEvent),
    infoEntity: map3infoEntity,
  );
});

var map3NodeBroadcaseSuccessHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  ContractNodeItem contractNodeItem;
  var item = params['contractNodeItem']?.first;
  if (item != null) {
    contractNodeItem = ContractNodeItem.fromJson(FluroConvertUtils.string2map(item));
  }
  return Map3NodeBroadcaseSuccessPageV8(
    params['pageType']?.first,
    contractNodeItem: contractNodeItem,
  );
});

var map3NodeContractDetailHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);

  Map3InfoEntity entity = Map3InfoEntity.fromJson(FluroConvertUtils.string2map(params['info']?.first));

  return Map3NodeDetailPage(entity);
});

var map3NodeContractDetailHandlerV8 = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);

  return Map3NodeContractDetailPageV8(int.parse(params['contractId']?.first));
});

var map3NodeShareHandler = Handler(handlerFunc: (context, params) {
  Map3InfoEntity map3infoEntity = Map3InfoEntity.fromJson(FluroConvertUtils.string2map(params['info']?.first));
  return Map3NodeSharePage(map3infoEntity);
});

var map3AtlasNodeShareHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);

  Map3InfoEntity entity = Map3InfoEntity.fromJson(FluroConvertUtils.string2map(params['info']?.first));

  return Map3NodeDetailPage(entity);
});

var map3NodeIntroductionHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return Map3NodeIntroductionPage();
});

var map3NodeMyHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return Map3NodeMyPage();
});

var map3NodeMyHandlerV8 = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return MyContractsPageV8();
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
  Map3InfoEntity map3infoEntity = Map3InfoEntity.fromJson(FluroConvertUtils.string2map(params['info']?.first));
  return Map3NodeExitPage(
    map3infoEntity: map3infoEntity,
  );
});

var map3NodeCollectHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  return Map3NodeCollectPage();
});

var map3NodeCancelHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  Map3InfoEntity map3infoEntity = Map3InfoEntity.fromJson(FluroConvertUtils.string2map(params['info']?.first));
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

var atlasCreateNodeConfirmHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  CreateAtlasPayload _createAtlasPayload =
      CreateAtlasPayload.fromJson(FluroConvertUtils.string2map(params['createAtlasPayload']?.first));
  return AtlasNodeCreateConfirmPage(_createAtlasPayload);
});

var atlasBroadcastSuccessHandler = Handler(handlerFunc: (context, params) {
  _cacheEntryRouteName(params);
  var actionEvent = params['actionEvent']?.first;
  return AtlasBroadcastSuccessPage(
    actionEvent: atlasActionEventFromString(actionEvent),
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
