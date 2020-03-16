import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/wallet/wallet_create_backup_notice_page.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/validator_util.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateAccountState();
  }
}

class _CreateAccountState extends State<CreateAccountPage> {
  TextEditingController _walletNameController = TextEditingController();
  TextEditingController _walletPasswordController = TextEditingController();
  TextEditingController _walletConfimPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            S.of(context).create_wallet,
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: 72,
                    height: 72,
                    child: Image.asset("res/drawable/hyn_icon.png"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 64),
                    child: Text(
                      S.of(context).create_wallet_tips,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        S.of(context).create_wallet_name_label,
                        style: TextStyle(
                          color: HexColor('#333333'),
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    child: TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return S.of(context).input_wallet_name_hint;
                          } else if (value.length > 6) {
                            return S.of(context).input_wallet_name_length_hint;
                          } else {
                            return null;
                          }
                        },
                        controller: _walletNameController,
                        decoration: InputDecoration(
                          hintText: S.of(context).input_wallet_name_length_hint,
                          hintStyle: TextStyle(color: HexColor('#AAAAAA'), fontSize: 13),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        maxLength: 6,
                        keyboardType: TextInputType.text),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        S.of(context).create_wallet_password_label,
                        style: TextStyle(
                          color: HexColor('#333333'),
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    child: TextFormField(
                      validator: (value) {
                        if (!ValidatorUtil.validatePassword(value)) {
                          return S.of(context).input_wallet_password_length_hint;
                        } else {
                          return null;
                        }
                      },
                      controller: _walletPasswordController,
                      decoration: InputDecoration(
                        hintText: S.of(context).input_wallet_password_length_hint,
                        hintStyle: TextStyle(color: HexColor('#AAAAAA'), fontSize: 13),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        S.of(context).reinput_wallet_password_label,
                        style: TextStyle(
                          color: HexColor('#333333'),
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return S.of(context).input_password_again_hint;
                        } else if (value != _walletPasswordController.text) {
                          return S.of(context).password_not_equal_hint;
                        } else {
                          return null;
                        }
                      },
                      controller: _walletConfimPasswordController,
                      decoration: InputDecoration(
                        hintText: S.of(context).input_confirm_wallet_password_hint,
                        hintStyle: TextStyle(color: HexColor('#AAAAAA'), fontSize: 13),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 24, 0, 48),
                    constraints: BoxConstraints.expand(height: 48),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      disabledColor: Colors.grey[600],
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      disabledTextColor: Colors.white,
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          var walletName = _walletNameController.text;
                          var password = _walletPasswordController.text;

//                          createWalletNameTemp = walletName;
//                          createWalletPasswordTemp = password;
                          Application.router.navigateTo(context, Routes.wallet_backup_notice_for_creation
                              + '?walletName=$walletName&password=$password');

//                          Navigator.push(
//                              context, MaterialPageRoute(builder: (context) => CreateWalletBackupNoticePage()));
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              S.of(context).next,
                              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
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
        ));
  }
}
