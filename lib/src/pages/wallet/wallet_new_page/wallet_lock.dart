import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/app_lock/app_lock_component.dart';
import 'package:titan/src/components/app_lock/util/app_lock_util.dart';
import 'package:titan/src/pages/bio_auth/bio_auth_page.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/auth_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class WalletLock extends StatefulWidget {
  final Function onUnlock;
  final bool isDialog;

  WalletLock({
    @required this.onUnlock,
    this.isDialog,
  });

  @override
  BaseState<StatefulWidget> createState() {
    return _WalletLockState();
  }
}

class _WalletLockState extends BaseState<WalletLock> {
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      _bioAuth();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onCreated() {
    super.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    Duration insetAnimationDuration = const Duration(milliseconds: 100);
    Curve insetAnimationCurve = Curves.decelerate;
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets + const EdgeInsets.symmetric(horizontal: 32.0),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                          child: Image.asset(
                            'res/drawable/img_safe_lock.png',
                            width: 70,
                            height: 70,
                          ),
                        ),
                        Text(
                          '请输入密码',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Container(
                          width: 200,
                          child: PinPut(
                            preFilledWidget: Container(
                              width: 15,
                              height: 3,
                              color: Colors.black,
                            ),
                            eachFieldConstraints: const BoxConstraints(
                              minHeight: 20.0,
                              minWidth: 20.0,
                            ),
                            obscureText: '●',
                            fieldsCount: 6,
                            onSubmit: (String pin) => _submit(pin),
                            focusNode: _pinPutFocusNode,
                            controller: _pinPutController,
                            autofocus: true,
                          ),
                        ),
                        if (AppLockInheritedModel.of(context).walletLockPwdHint != null)
                          InkWell(
                            child: Text(
                              '密码提示',
                              style: TextStyle(
                                color: HexColor('#E7BB00'),
                                fontSize: 14,
                              ),
                            ),
                            onTap: () {
                              Fluttertoast.showToast(
                                  msg: '${AppLockInheritedModel.of(context).walletLockPwdHint}');
                            },
                          )
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.isDialog ?? false)
                Positioned(
                  top: 16,
                  left: 16,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Image.asset(
                      'res/drawable/ic_close.png',
                      width: 12,
                      height: 12,
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  _submit(String pin) async {
    if (await AppLockUtil.checkWalletLockPwd(pin)) {
      widget.onUnlock?.call();
    } else {
      UiUtil.showErrorTopHint(
        context,
        '密码错误，请重试',
      );
      _pinPutController.text = '';
    }
  }

  _bioAuth() async {
    if (AppLockInheritedModel.of(context).isWalletLockBioAuthEnabled) {
      var authConfig = await AuthUtil.getAuthConfig(
        null,
        authType: AuthType.walletLock,
      );

      var result = await AuthUtil.bioAuth(
        context,
        AuthUtil.currentBioMetricType(authConfig),
      );

      if (result) {
        widget.onUnlock?.call();
      }
    }
  }
}
