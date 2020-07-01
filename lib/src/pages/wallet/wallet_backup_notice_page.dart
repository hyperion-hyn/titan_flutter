import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/wallet/wallet_backup_show_resume_word_page.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';

class WalletBackupNoticePage extends StatefulWidget {
  Wallet wallet;

  WalletBackupNoticePage(this.wallet);

  @override
  State<StatefulWidget> createState() {
    return _WalletBackupNoticeState();
  }
}

class _WalletBackupNoticeState extends State<WalletBackupNoticePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        height: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(
                            S.of(context).backup_notice_label,
                            style: TextStyle(
                                fontSize: 22,
                                color: Color(0xFF252525),
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          Text(
                            S.of(context).backup_wallet_notice_text1,
                            style: TextStyle(
                                fontSize: 14, color: Color(0xFF9B9B9B)),
                            softWrap: true,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Image.asset(
                              "res/drawable/backup_notice_image.png",
                              height: 130,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 24.0,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  S.of(context).backup_wallet_mnemonic_title,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              S.of(context).backup_wallet_mnemonic_text,
                              style: TextStyle(
                                height: 1.8,
                                fontSize: 15,
                                color: Color(0xFF6D6D6D),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 24,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              S.of(context).backup_offline_save_title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              S.of(context).backup_offline_save_text,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.8,
                                color: Color(0xFF6D6D6D),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 30, horizontal: 36),
                  constraints: BoxConstraints.expand(height: 48),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    disabledColor: Colors.grey[600],
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    disabledTextColor: Colors.white,
                    onPressed: () {
                      _showSecurityDialog();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            S.of(context).next,
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 16),
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
    );
  }

  _showSecurityDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: Container(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0, bottom: 25),
                      child: Image.asset(
                        'res/drawable/ic_snap.png',
                        width: 60,
                        height: 60,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(S.of(context).no_screenshot_dialog_title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
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
                    Spacer(),
                    Container(
                      width: double.infinity,
                      color: Colors.grey[200],
                      height: 1,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: FlatButton(
                            child: Text(
                              S.of(context).no_screenshot_dialog_cancel,
                              style: TextStyle(
                                color: HexColor('#FF9B9B9B'),
                                fontSize: 16,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        Container(
                          width: 1,
                          color: Colors.grey[200],
                          height: 24.0,
                        ),
                        Expanded(
                          flex: 1,
                          child: FlatButton(
                            child: Text(
                              S.of(context).no_screenshot_dialog_confirm,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showVerifyDialog();
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  _showVerifyDialog() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        builder: (BuildContext context) {
          return EnterWalletPasswordWidget();
        }).then((walletPassword) async {
      print("walletPassword:$walletPassword");
      if (walletPassword == null) {
        return;
      }
      var wallet = widget.wallet;
      try {
        if ((wallet.keystore is KeyStore) && wallet.keystore.isMnemonic) {
          var mnemonic = await WalletUtil.exportMnemonic(
              fileName: wallet.keystore.fileName, password: walletPassword);
          logger.i('your mnemonic is: $mnemonic');
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      BackupShowResumeWordPage(wallet, mnemonic)));
        } else {
          print(S.of(context).isnt_trustwallet_cant_export);
        }
      } catch (_) {
        _ as PlatformException;
        logger.e(_);
        if (_.code == WalletError.PASSWORD_WRONG) {
          Fluttertoast.showToast(msg: S.of(context).wallet_password_error);
        } else {
          Fluttertoast.showToast(msg: S.of(context).extract_mnemonic_fail);
        }
      }
    });
  }
}
