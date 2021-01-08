import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/wallet/wallet_new_page/wallet_backup_show_seed_phrase_page_v2.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/screenshot_warning_dialog.dart';

class WalletBackupNoticePageV2 extends StatefulWidget {
  final Wallet wallet;

  WalletBackupNoticePageV2(this.wallet);

  @override
  State<StatefulWidget> createState() {
    return _WalletBackupNoticeState();
  }
}

class _WalletBackupNoticeState extends State<WalletBackupNoticePageV2> {
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Image.asset(
                    "res/drawable/backup_notice_image.png",
                    height: 130,
                  ),
                ),
                SizedBox(
                  height: 32,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            S.of(context).backup_notice_label,
                            style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF252525),
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            S.of(context).backup_wallet_notice_text1,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9B9B9B),
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 24.0,
                  ),
                  child: Divider(
                    height: 1,
                    thickness: 0.5,
                    color: DefaultColors.colorf2f2f2,
                  ),
                ),
                _reminder('助记词由英文单词组成，请抄写并妥善保管。'),
                SizedBox(
                  height: 16,
                ),
                _reminder('助记词丢失，无法找回，请务必备份助记词。'),
                SizedBox(
                  height: 120,
                ),
                ClickOvalButton(
                  '下一步',
                  () {
                    _showScreenshotWarningDailog();
                  },
                  width: 300,
                  height: 46,
                  btnColor: [
                    HexColor("#F7D33D"),
                    HexColor("#E7C01A"),
                  ],
                  fontSize: 16,
                  fontColor: DefaultColors.color333,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _reminder(String text) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DefaultColors.color999,
                border: Border.all(color: DefaultColors.color999, width: 1.0)),
          ),
        ),
        Expanded(
          child: Text(
            '$text',
            style: TextStyle(
              fontSize: 14,
              color: DefaultColors.color999,
            ),
          ),
        )
      ],
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
                    WalletBackupShowSeedPhrasePageV2(wallet, mnemonic)));
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
