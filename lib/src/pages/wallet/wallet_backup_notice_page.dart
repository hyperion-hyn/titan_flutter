import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/i18n.dart';
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
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            S.of(context).backup_notice_label,
                            style: TextStyle(fontSize: 22, color: Color(0xFF252525)),
                          ),
                        ),
                        Text(
                          S.of(context).backup_wallet_notice_text1,
                          style: TextStyle(fontSize: 14, color: Color(0xFF9B9B9B)),
                          softWrap: true,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Image.asset(
                            "res/drawable/backup_notice_image.png",
                            height: 128,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("●"),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          S.of(context).backup_wallet_mnemonic_title,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          S.of(context).backup_wallet_mnemonic_text,
                          style: TextStyle(fontSize: 15, color: Color(0xFF6D6D6D)),
                        )
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("●"),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          S.of(context).backup_offline_save_title,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          S.of(context).backup_offline_save_text,
                          style: TextStyle(fontSize: 15, color: Color(0xFF6D6D6D)),
                        )
                      ],
                    ),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 30, horizontal: 36),
                constraints: BoxConstraints.expand(height: 48),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  disabledColor: Colors.grey[600],
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  disabledTextColor: Colors.white,
                  onPressed: () {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
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
                          //logger.i('your mnemonic is: $mnemonic');
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => BackupShowResumeWordPage(wallet, mnemonic)));
                        } else {
                          print('不是TrustWallet钱包，不支持导出助记词');
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
    );
  }
}
