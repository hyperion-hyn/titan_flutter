import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';

// ignore: must_be_immutable
class CreateWalletBackupNoticePage extends StatefulWidget {
  String mnemoic;
  String walletName;
  String password;

  CreateWalletBackupNoticePage(this.walletName, this.password);

  @override
  State<StatefulWidget> createState() {
    return _CreateWalletBackupNoticePageState();
  }
}

class _CreateWalletBackupNoticePageState extends State<CreateWalletBackupNoticePage> {
  bool _noticeCheckboxChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Container(
          color: Colors.white,
          padding: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  S.of(context).account_backup_notice,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF252525),
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  S.of(context).account_backup_next_step_notice,
                  style: TextStyle(
                    color: HexColor('#FF9B9B9B'),
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Image.asset(
                  "res/drawable/backup_wallet_main.png",
                  height: 200,
                  width: 200,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _noticeCheckboxChecked = !_noticeCheckboxChecked;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      _noticeCheckboxChecked
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  _noticeCheckboxChecked = !_noticeCheckboxChecked;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  'res/drawable/ic_checkbox_checked.png',
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                'res/drawable/ic_checkbox_unchecked.png',
                                width: 20,
                                height: 20,
                              ),
                            ),
                      Flexible(
                        child: Text(
                          S.of(context).lossz_wallet_mnemonic_notice,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 36,
                ),
                constraints: BoxConstraints.expand(height: 48),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  disabledColor: HexColor('#dedede'),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  disabledTextColor: HexColor('#999999'),
                  onPressed: _noticeCheckboxChecked ? _next : null,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          S.of(context).continue_text,
                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void _next() {
    var walletName = FluroConvertUtils.fluroCnParamsEncode(widget.walletName);
    Application.router
        .navigateTo(context, Routes.wallet_show_resume_word + '?walletName=$walletName&password=${widget.password}');
  }
}
