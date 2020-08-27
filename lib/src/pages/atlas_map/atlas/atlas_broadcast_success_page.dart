import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/routes/routes.dart';

class AtlasBroadcastSuccessPage extends StatelessWidget {
  final AtlasNodeActionEvent actionEvent;

  AtlasBroadcastSuccessPage({this.actionEvent});

  @override
  Widget build(BuildContext context) {
    String action = "";
    String detail = "";
    switch (actionEvent) {
      case AtlasNodeActionEvent.CREATE:
        action = "创建 Atlas节点";
        detail = "距离节点启动还需800000HYN，你可以邀请 好友参与抵押加速节点启动吧~";
        break;

      default:
        break;
    }
    action = "已在区块链上网络广播 【$action】的消息，区块链网络需要约6秒开采验证。";

    return WillPopScope(
      onWillPop: () async {
        _pop(context);
        return false;
      },
      child: Scaffold(
          body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    top: 50 + MediaQuery.of(context).padding.top, bottom: 27),
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
                    style: TextStyle(
                        fontSize: 20,
                        color: HexColor("#333333"),
                        fontWeight: FontWeight.w500)),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48, vertical: 12),
                      child: Text(
                        detail,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: HexColor("#0A6F84"),
                            height: 1.5),
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
                            side: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(36)),
                        onPressed: () {
                          if (detail.isNotEmpty) {
                            Share.text(S.of(context).share, "http://baidu.com",
                                'text/plain');
                          } else {
                            _pop(context);
                          }
                        },
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40.0, vertical: 12.0),
                            child: Text(
                              detail.isEmpty ? "完成" : "分享邀请",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (detail.isNotEmpty)
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                        child: Container(
                          constraints: BoxConstraints.expand(height: 48),
                          child: FlatButton(
                            //color: this.contractNodeItem == null?Theme.of(context).primaryColor:null,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(36)),
                            onPressed: () {
                              _pop(context);
                            },
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40.0, vertical: 12.0),
                                child: Text(
                                  "查看节点",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).primaryColor),
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
      case AtlasNodeActionEvent.CREATE:
        Routes.popUntilCachedEntryRouteName(context);
        break;
      default:
        Routes.popUntilCachedEntryRouteName(context, true);
        break;
    }
  }
}
