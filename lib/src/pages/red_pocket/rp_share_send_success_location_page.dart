import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class RpShareSendSuccessLocationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RpShareSendSuccessLocationState();
  }
}

class _RpShareSendSuccessLocationState extends State<RpShareSendSuccessLocationPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String action = "请等待交易确认后就可以在泰坦地图上找到你的红包啦～";

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
                      color: HexColor("#FF4D4D"),
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
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 60,
              ),
              ClickOvalButton(
                '已完成',
                () {
                  _pop(context);
                },
                btnColor: [HexColor("#FF4D4D"), HexColor("#FF0527")],
                fontSize: 16,
                width: 260,
                height: 42,
              ),
            ],
          ),
        ),
      )),
    );
  }

  void _pop(BuildContext context) {
    Routes.popUntilCachedEntryRouteName(context, true);
  }
}
