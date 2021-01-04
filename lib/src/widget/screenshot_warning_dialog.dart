import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class ScreenshotWarningDialog extends StatefulWidget {
  final Function onConfirm;

  ScreenshotWarningDialog({
    @required this.onConfirm,
  });

  @override
  BaseState<StatefulWidget> createState() {
    return _ScreenshotWarningDialogState();
  }
}

class _ScreenshotWarningDialogState extends BaseState<ScreenshotWarningDialog> {
  void initState() {
    super.initState();
    // TODO: implement initState
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void onCreated() {
    // TODO: implement onCreated
    super.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    Duration insetAnimationDuration = const Duration(milliseconds: 100);
    Curve insetAnimationCurve = Curves.decelerate;
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.symmetric(horizontal: 32.0),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                        child: Image.asset(
                          'res/drawable/ic_snap.png',
                          width: 80,
                          height: 80,
                          color: DefaultColors.primary,
                        ),
                      ),
                      Center(
                        child: Text(S.of(context).no_screenshot_dialog_title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 16.0,
                        ),
                        child: Text(
                          S.of(context).warning_no_sceenshot,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: HexColor('#FF6D6D6D'),
                            height: 1.7,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                        child: ClickOvalButton(
                          S.of(context).no_screenshot_dialog_confirm,
                          () {
                            Navigator.of(context).pop();
                            widget.onConfirm();
                          },
                          width: 200,
                          height: 38,
                          btnColor: [
                            HexColor("#F7D33D"),
                            HexColor("#E7C01A"),
                          ],
                          fontSize: 16,
                          fontColor: DefaultColors.color333,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
