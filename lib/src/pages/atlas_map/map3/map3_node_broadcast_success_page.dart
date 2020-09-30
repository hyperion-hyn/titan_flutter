import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/routes/routes.dart';

class Map3NodeBroadcastSuccessPage extends StatelessWidget {
  final Map3NodeActionEvent actionEvent;
  final ContractNodeItem contractNodeItem;
  Map3NodeBroadcastSuccessPage({this.actionEvent, this.contractNodeItem});

  @override
  Widget build(BuildContext context) {
    String action = "";
    String detail = "";
    switch (actionEvent) {
      case Map3NodeActionEvent.CREATE:
        action = "创建 Map3节点";
        detail = "距离节点启动还需800000HYN，你可以邀请 好友参与抵押加速节点启动吧~";
        break;

      case Map3NodeActionEvent.DELEGATE:
        action = "参与 Map3节点";
        detail = "距离节点启动还需800000HYN，你可以邀请 好友参与抵押加速节点启动吧~";
        break;

      case Map3NodeActionEvent.COLLECT:
        action = "Map3提币";
        break;

      case Map3NodeActionEvent.CANCEL:
        action = "Map3撤销抵押";
        break;

      case Map3NodeActionEvent.CANCEL_CONFIRMED:
        action = "Map3取消节点";
        break;

      case Map3NodeActionEvent.ADD:
        action = "Map3节点分裂";
        break;

      case Map3NodeActionEvent.RECEIVE_AWARD:
        action = "提取奖励";
        break;

      case Map3NodeActionEvent.EDIT_ATLAS:
        action = "编辑Atlas节点";
        break;

      case Map3NodeActionEvent.ACTIVE_NODE:
        action = "激活Atlas节点";
        break;

      case Map3NodeActionEvent.STAKE_ATLAS:
        action = "激活Atlas节点";
        break;

      default:
        break;
    }
    action = "已在区块链上网络广播 【$action】的消息，区块链网络需要约6秒开采验证。";
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                      child: Text(
                        detail,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600, color: HexColor("#0A6F84"), height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (detail.isNotEmpty)
                      Image.asset(
                        "res/drawable/node_create_success.gif",
                        fit: BoxFit.contain,
                        width: 26,
                      ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 48),
                      constraints: BoxConstraints.expand(height: 48),
                      child: FlatButton(
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(36)),
                        onPressed: () {
                          if (detail.isNotEmpty) {
                            Share.text(S.of(context).share, "http://baidu.com", 'text/plain');
                          } else {
                            _pop(context);
                          }
                        },
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                            child: Text(
                              detail.isEmpty ? "完成" : "分享邀请",
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

                              //Routes.popUntilCachedEntryRouteName(context);

//                              Application.router.navigateTo(
//                                  context,
//                                  Routes.wallet_import +
//                                      '?entryRouteName=${Uri.encodeComponent(Routes.map3node_product_list)}');
                            },
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                                child: Text(
//                                  S.of(context).finish,
                                  "查看节点",
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

  void _pop(BuildContext context) {
    switch (actionEvent) {
      case Map3NodeActionEvent.CREATE:
        print("[pop] -----> _pop, contractNodeItem:${this.contractNodeItem.toJson()}");

        Routes.popUntilCachedEntryRouteName(context, this.contractNodeItem);
        break;

      default:
        print("[pop] -----> _pop, contractNodeItem");

        Routes.popUntilCachedEntryRouteName(context, true);
        break;
    }
  }
}
