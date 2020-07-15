import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/wallet/wallet_create_backup_notice_page.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/validator_util.dart';
import 'package:titan/src/widget/keyboard/wallet_password_dialog.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateAccountState();
  }
}

class _CreateAccountState extends State<CreateAccountPage> {
  TextEditingController _walletNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isShowPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            S.of(context).create_wallet,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              // hide keyboard when touch other widgets
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Form(
              key: _formKey,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      width: 64,
                      height: 64,
                      child: Image.asset("res/drawable/ic_hyn_logo_new.png"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 50),
                      child: Text(
                        S.of(context).create_wallet_tips,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          S.of(context).create_wallet_name_label,
                          style: TextStyle(
                              color: HexColor('#333333'),
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 10),
                      child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return S.of(context).input_wallet_name_hint;
                            } else if (value.length > 6) {
                              return S
                                  .of(context)
                                  .input_wallet_name_length_hint;
                            } else {
                              return null;
                            }
                          },
                          controller: _walletNameController,
                          decoration: InputDecoration(
                            hintText:
                                S.of(context).input_wallet_name_length_hint,
                            hintStyle: TextStyle(
                              color: HexColor('#AAAAAA'),
                              fontSize: 13,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: HexColor('#FFD0D0D0'),
                                width: 0.5,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: HexColor('#FFD0D0D0'),
                                width: 0.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: HexColor('#FFD0D0D0'),
                                width: 0.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 0.5,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(6),
                          ],
                          keyboardType: TextInputType.text),
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 24, 0, 48),
                      constraints: BoxConstraints.expand(height: 48),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        disabledColor: Colors.grey[600],
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        disabledTextColor: Colors.white,
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            var walletName =
                                FluroConvertUtils.fluroCnParamsEncode(
                                    _walletNameController.text);
                            var password =
                                await UiUtil.showDoubleCheckPwdDialog(context);
                            if (password != null) {
                              Application.router.navigateTo(
                                  context,
                                  Routes.wallet_backup_notice_for_creation +
                                      '?walletName=$walletName&password=$password');
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                S.of(context).next,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
