import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/app_lock/app_lock_bloc.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textField.dart';

class AppLockSetPwdPage extends StatefulWidget {
  final Function onPwdSet;

  AppLockSetPwdPage({this.onPwdSet});

  @override
  State<StatefulWidget> createState() {
    return _AppLockSetPwdState();
  }
}

class _AppLockSetPwdState extends BaseState<AppLockSetPwdPage> {
  TextEditingController _pwdController = TextEditingController();
  TextEditingController _confirmPwdController = TextEditingController();
  TextEditingController _pwdHintController = TextEditingController();
  bool _isShowPwd = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: _content(),
    );
  }

  _content() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8),
                    child: Text(
                      S.of(context).set_app_lock_pwd,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 32),
                        RoundBorderTextField(
                            keyboardType: TextInputType.number,
                            hintText: S.of(context).pwd_shorter_than_six,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(6),
                              FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                            ],
                            obscureText: !_isShowPwd,
                            suffixIcon: Container(
                              width: 10,
                              child: Align(
                                alignment: Alignment.center,
                                child: InkWell(
                                  onTap: () {
                                    if (mounted)
                                      setState(() {
                                        _isShowPwd = !_isShowPwd;
                                      });
                                  },
                                  child: Image.asset(
                                    _isShowPwd
                                        ? "res/drawable/ic_input_psw_show.png"
                                        : "res/drawable/ic_input_psw_hide.png",
                                    width: 20,
                                    height: 15,
                                  ),
                                ),
                              ),
                            ),
                            onChanged: (text) {
                              setState(() {});
                            },
                            controller: _pwdController,
                            isDense: false,
                            borderRadius: 6,
                            validator: (inputValue) {
                              if (inputValue.length < 6) {
                                return S.of(context).pwd_shorter_than_six;
                              }
                              return null;
                            }),
                        SizedBox(
                          height: 16,
                        ),
                        RoundBorderTextField(
                            keyboardType: TextInputType.number,
                            hintText: S.of(context).input_password_again_hint,
                            onChanged: (text) {
                              setState(() {});
                            },
                            controller: _confirmPwdController,
                            isDense: false,
                            borderRadius: 6,
                            obscureText: !_isShowPwd,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(6),
                              FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                            ],
                            validator: (confrimValue) {
                              if (confrimValue.length < 6) {
                                return S.of(context).pwd_shorter_than_six;
                              }
                              if (confrimValue != _pwdController.text) {
                                return S.of(context).password_not_equal_hint;
                              }
                              return null;
                            }),
                        SizedBox(
                          height: 16,
                        ),
                        RoundBorderTextField(
                          keyboardType: TextInputType.text,
                          hintText: '${S.of(context).pwd_hint}(${S.of(context).optional})',
                          onChanged: (text) {
                            setState(() {});
                          },
                          controller: _pwdHintController,
                          isDense: false,
                          borderRadius: 6,
                        ),
                        SizedBox(height: 64),
                        ClickOvalButton(
                          S.of(context).confirm,
                          () {
                            if (_formKey.currentState.validate()) {
                              BlocProvider.of<AppLockBloc>(context).add(
                                SetAppLockPwdEvent(
                                  _pwdController.text,
                                  _pwdHintController.text,
                                ),
                              );
                              widget.onPwdSet?.call();
                              Navigator.of(context).pop();
                            }
                          },
                          width: 300,
                          height: 46,
                          btnColor: [
                            HexColor("#F7D33D"),
                            HexColor("#E7C01A"),
                          ],
                          fontSize: 16,
                          fontColor: DefaultColors.color333,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
