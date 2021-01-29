import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/pages/bio_auth/bio_auth_page.dart';
import 'package:titan/src/components/auth/auth_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/wallet/forgot_wallet_password_page.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/validator_util.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textField.dart';

import 'keyboard/wallet_password_dialog.dart';

class EnterWalletPasswordWidget extends StatefulWidget {
  final bool useDigits;
  final CheckPwdValid onPwdSubmitted;
  final bool isShowBioAuthIcon;
  final Wallet wallet;
  final AuthType authType;
  final String remindStr;

  EnterWalletPasswordWidget({
    this.useDigits = false,
    this.onPwdSubmitted,
    this.isShowBioAuthIcon = true,
    this.authType,
    this.remindStr,
    this.wallet,
  });

  @override
  State<StatefulWidget> createState() {
    return EnterWalletPasswordState();
  }
}

class EnterWalletPasswordState extends BaseState<EnterWalletPasswordWidget> {
  int _countdownTime = 0;
  Timer _timer;

  String walletEditErrorMsg;

  final _formKey = GlobalKey<FormState>();

  TextEditingController passwordEditingController = TextEditingController();

  bool _isHideLayout = false;

  @override
  void onCreated() {
    super.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _isHideLayout
            ? SizedBox()
            : Center(
              child: Container(
                margin: const EdgeInsets.only(left:38.0,right: 38),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16),),
                  color: Colors.white,
                ),
                child: Stack(
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Container(
                          padding: const EdgeInsets.only(left:24.0,right: 24,bottom: 26),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top:29.0,bottom: 20),
                                  child: Text(
                                    S.of(context).please_input_wallet_password_hint,
                                    style: TextStyles.textC333S16bold,
                                  ),
                                ),
                                if(widget.remindStr != null)
                                  Text(
                                    widget.remindStr,
                                    style: TextStyles.textC333S12,
                                  ),
                                SizedBox(height: 12,),
                                RoundBorderTextField(
                                  inputFormatters: [
//                                if (widget.useDigits)
//                                  LengthLimitingTextInputFormatter(6),
                                  ],
                                  controller: passwordEditingController,
                                  keyboardType: TextInputType.visiblePassword,
                                  errorText: walletEditErrorMsg != null ? walletEditErrorMsg : null,
                                ),
                                Row(
                                  children: <Widget>[
                                    Spacer(),
                                    InkWell(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 14.0),
                                        child: Text(
                                          S.of(context).forgot_password,
                                          style: TextStyle(color: HexColor('#E7BB00')),
                                        ),
                                      ),
                                      onTap: () {
                                        Fluttertoast.showToast(msg: "密码提示：${widget.wallet.walletExpandInfoEntity.pswRemind ?? ""}");
                                      },
                                    )
                                  ],
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top:10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset(
                                          'res/drawable/ic_wallet.png',
                                          width: 20,
                                          height: 20,
                                        ),
                                        SizedBox(
                                          width: 9,
                                        ),
                                        Text(
                                          widget.wallet.keystore.name,
                                          style: TextStyle(
                                            color: HexColor('#FF999999'),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top:12),
                                    child: ClickOvalButton(
                                      S.of(context).confirm,
                                          () async {
                                        var inputText = passwordEditingController.text;
                                        var result = await widget.onPwdSubmitted(inputText);
                                        if (result) {
                                          Navigator.of(context).pop(inputText);
                                        } else {
                                          setState(() {
                                            walletEditErrorMsg = S.of(context).wallet_password_error;
                                          });
                                        }
                                      },
                                      width: 200,
                                      height: 38,
                                      btnColor: [HexColor("#F7D33D"),HexColor("#E7C01A"),],
                                      fontColor: HexColor("#333333"),
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              ])),
                    ),
                    GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.all(17.0),
                        child: Image.asset(
                          'res/drawable/rp_share_close.png',
                          width: 13,
                          height: 13,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    if (widget.isShowBioAuthIcon)
                      Positioned(
                        right: 16,
                        top: 16,
                        child: GestureDetector(
                          onTap: () {
                            _goToBioAuthSettingPage();
                          },
                          child: _bioAuthIcon(),
                        ),
                      )
                  ],
                ),
              ),
            ),
      ),
    );
  }

  _bioAuthIcon() {
    if (AuthInheritedModel.of(
      context,
      aspect: AuthAspect.config,
    ).bioAuthAvailable) {
      if (AuthInheritedModel.of(
            context,
            aspect: AuthAspect.config,
          ).availableBioMetricType ==
          BiometricType.face) {
        return Image.asset(
          'res/drawable/ic_face_id.png',
          width: 20,
          height: 20,
        );
      } else if (AuthInheritedModel.of(
            context,
            aspect: AuthAspect.config,
          ).availableBioMetricType ==
          BiometricType.fingerprint) {
        return Image.asset(
          'res/drawable/ic_fingerprint.png',
          color: HexColor("#E7BB00"),
          width: 20,
          height: 20,
        );
      } else {
        return SizedBox();
      }
    } else {
      return SizedBox();
    }
  }

  _goToBioAuthSettingPage() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BioAuthPage(
                  widget.wallet,
                  widget.authType,
                )));
    setState(() {
      _isHideLayout = true;
    });

    ///Show password dialog again
    var pwd = await UiUtil.showWalletPasswordDialogV2(
      context,
      widget.wallet,
      authType: widget.authType,
    );
    Navigator.of(context).pop(pwd);
  }

  void startCountdownTimer() {
    const oneSec = const Duration(seconds: 1);

    var callback = (timer) => {
          setState(() {
            if (_countdownTime < 1) {
              _timer.cancel();
            } else {
              _countdownTime = _countdownTime - 1;
            }
          })
        };

    _timer = Timer.periodic(oneSec, callback);
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }
}
