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
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/screenshot_warning_dialog.dart';
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
                      _showScreenshotWarningDailog();
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

  _showScreenshotWarningDailog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ScreenshotWarningDialog(
            onConfirm: _showVerifyDialog,
          );
        });
  }

  _showVerifyDialog() async {
    var walletPassword = await UiUtil.showWalletPasswordDialogV2(
      context,
      widget.wallet,
    );

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
  }
}
