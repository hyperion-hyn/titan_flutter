import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

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
        detail = '';
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
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.8,
                  ),
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
                    SizedBox(
                      height: 32,
                    ),
                    ClickOvalButton(
                      '完成',
                      () {
                        _pop(context);
                      },
                      height: 46,
                      width: 300,
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
