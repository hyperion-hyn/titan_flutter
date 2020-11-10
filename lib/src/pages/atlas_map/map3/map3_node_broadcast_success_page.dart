import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_introduce_entity.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/format_util.dart';

import '../../../../env.dart';

class Map3NodeBroadcastSuccessPage extends StatefulWidget {
  final Map3NodeActionEvent actionEvent;
  final Map3InfoEntity infoEntity;

  Map3NodeBroadcastSuccessPage({this.actionEvent, this.infoEntity});

  @override
  State<StatefulWidget> createState() {
    return _Map3NodeBroadcastSuccessState();
  }
}

class _Map3NodeBroadcastSuccessState extends State<Map3NodeBroadcastSuccessPage> {
  Map3IntroduceEntity _map3introduceEntity;

  @override
  void initState() {
    setupData();

    super.initState();
  }

  setupData() async {
    _map3introduceEntity = await AtlasApi.getIntroduceEntity();
  }

  @override
  Widget build(BuildContext context) {
    String action = "";
    String detail = "";
    switch (widget.actionEvent) {
      case Map3NodeActionEvent.MAP3_CREATE:
        action = S.of(context).action_create_map3;

        var startMin = double.parse(_map3introduceEntity?.startMin ?? "0");
        var staking = double.parse(widget.infoEntity.staking);
        var remain = startMin - staking;
        if (remain < 0) {
          remain = 0;
        }
        detail = S.of(context).detail_share_map3('${FormatUtil.formatPrice(remain)}');
        break;

      case Map3NodeActionEvent.MAP3_DELEGATE:
        var startMin = double.parse(_map3introduceEntity?.startMin ?? "0");
        var staking = double.parse(widget.infoEntity.staking);
        var pending = double.parse(widget.infoEntity.totalPendingStaking);
        var remain = startMin - staking - pending;
        if (remain < 0) {
          remain = 0;
        }
        action = S.of(context).action_delegate_map3;
        detail = S.of(context).detail_share_map3('${FormatUtil.formatPrice(remain)}');
        break;

      case Map3NodeActionEvent.MAP3_COLLECT:
        action = S.of(context).action_map3_collect;
        lastCollectDate = DateTime.now().millisecondsSinceEpoch;
        break;

      case Map3NodeActionEvent.MAP3_CANCEL:
        action = S.of(context).action_map3_cancel;
        break;

      case Map3NodeActionEvent.MAP3_TERMINAL:
        action = S.of(context).action_map3_teminate;
        break;

      case Map3NodeActionEvent.MAP3_CANCEL_CONFIRMED:
        action = S.of(context).action_map3_cancel_confirmed;
        break;

      case Map3NodeActionEvent.MAP3_ADD:
        action = S.of(context).action_map3_add;
        break;

      case Map3NodeActionEvent.ATLAS_RECEIVE_AWARD:
        action = S.of(context).action_atals_receive_award;
        break;

      case Map3NodeActionEvent.MAP3_EDIT:
        action = S.of(context).action_map3_edit;
        break;

      case Map3NodeActionEvent.MAP3_PRE_EDIT:
        action = S.of(context).action_map3_pre_edit;
        break;

      case Map3NodeActionEvent.ATLAS_EDIT:
        action = S.of(context).action_atlas_edit;
        break;

      case Map3NodeActionEvent.ATLAS_ACTIVE_NODE:
        action = S.of(context).action_active_node;
        break;

      case Map3NodeActionEvent.ATLAS_STAKE:
        action = S.of(context).action_atlas_stake;
        break;

      case Map3NodeActionEvent.ATLAS_CANCEL_STAKE:
        action = S.of(context).action_cancel_stake;
        break;

      default:
        break;
    }
    action = S.of(context).atlas_brocast_message_success('$action');
    //action = "已在区块链上网络广播 【${action}的消息】区块链网络需要5-30分钟开采验证";

    return WillPopScope(
      onWillPop: () async {
        _pop(context);
        return false;
      },
      child: Scaffold(
          body: Container(
        color: Colors.white,
        child: Center(
//          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 50 + MediaQuery.of(context).padding.top, bottom: 27),
                child: Container(
                  height: 76,
                  width: 124,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: Image.asset(
                      "res/drawable/check_outline.png",
                      fit: BoxFit.contain,
                      width: 72,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(S.of(context).broadcase_success,
                    style: TextStyle(fontSize: 20, color: HexColor("#333333"), fontWeight: FontWeight.w500)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  action,
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 70),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
//                    Container(
//                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
//                      child: Text(
//                        detail,
//                        style: TextStyle(
//                            fontSize: 14, fontWeight: FontWeight.w600, color: HexColor("#0A6F84"), height: 1.5),
//                        textAlign: TextAlign.center,
//                      ),
//                    ),
//                    if (detail.isNotEmpty)
//                      Image.asset(
//                        "res/drawable/node_create_success.gif",
//                        fit: BoxFit.contain,
//                        width: 26,
//                      ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 48),
                      constraints: BoxConstraints.expand(height: 48),
                      child: FlatButton(
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(36)),
                        onPressed: () {
                          // todo: jison_1026
//                          if (detail.isNotEmpty) {
//                            _shareAction();
//                          } else {
//                            _pop(context);
//                          }
                          _pop(context);
                        },
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                            child: Text(
                              //detail.isEmpty ? "完成" : "分享邀请",
                              S.of(context).completed,
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (detail.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                        child: Container(
                          constraints: BoxConstraints.expand(height: 48),
                          child: FlatButton(
                            //color: this.contractNodeItem == null?Theme.of(context).primaryColor:null,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(36)),
                            onPressed: () {
                              _pop(context);
                            },
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                                child: Text(
//                                  S.of(context).finish,
                                  S.of(context).check_nodes,
                                  style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  /*
  void _shareAction() {
    if (widget.actionEvent != Map3NodeActionEvent.MAP3_CREATE) {
      Share.text(S.of(context).share, "http://baidu.com", 'text/plain');

      return;
    }

    Application.router.navigateTo(
        context,
        Routes.map3node_share_page +
            "?contractNodeItem=${FluroConvertUtils.object2string(widget.infoEntity.toJson())}");
  }
  */

  void _pop(BuildContext context) {
    switch (widget.actionEvent) {
      case Map3NodeActionEvent.MAP3_CREATE:
        print("[pop] -----> _pop, contractNodeItem:${widget.infoEntity.toJson()}");

        Routes.popUntilCachedEntryRouteName(context, widget.infoEntity);
        break;

      /*
      case Map3NodeActionEvent.MAP3_EDIT:
        print("[pop] -----> EDIT_MAP3, 返回Map3 detail");
        Routes.cachedEntryRouteName = Routes.map3node_contract_detail_page;
        Routes.popUntilCachedEntryRouteName(context);
        break;
        */

      default:
        print("[pop] -----> _pop, contractNodeItem");

        Routes.popUntilCachedEntryRouteName(context, true);
        break;
    }
  }
}
