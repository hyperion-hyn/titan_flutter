import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/pages/wallet/wallet_show_resume_word_page.dart';

class CreateWalletBackupNoticePage extends StatefulWidget {
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
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  S.of(context).account_backup_notice,
                  style: TextStyle(color: Color(0xFF252525), fontWeight: FontWeight.normal, fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  S.of(context).account_backup_next_step_notice,
                  style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Image.asset(
                  "res/drawable/backup_wallet_main.png",
                  height: 200,
                  width: 200,
                ),
              ),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _noticeCheckboxChecked,
                    onChanged: (value) {
                      setState(() {
                        _noticeCheckboxChecked = value;
                      });
                    },
                  ),
                  Flexible(
                    child: Text(
                      S.of(context).lossz_wallet_mnemonic_notice,
                      softWrap: true,
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 16, horizontal: 36),
                constraints: BoxConstraints.expand(height: 48),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  disabledColor: Colors.grey[600],
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  disabledTextColor: Colors.white,
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

  Function _next() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ShowResumeWordPage()));
  }
}
