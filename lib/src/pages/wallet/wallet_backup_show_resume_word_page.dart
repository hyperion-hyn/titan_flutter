import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/pages/wallet/wallet_backup_confirm_resume_word_page.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/utils/utile_ui.dart';

import 'mnemonic_qrcode_page.dart';

class BackupShowResumeWordPage extends StatefulWidget {
  final Wallet wallet;
  final String mnemonic;

  BackupShowResumeWordPage(this.wallet, this.mnemonic);

  @override
  State<StatefulWidget> createState() {
    return _BackupShowResumeWordState();
  }
}

class _BackupShowResumeWordState extends State<BackupShowResumeWordPage> {
  List _resumeWords = [];

  @override
  void initState() {
    getMnemonic();
    super.initState();
  }

  Future getMnemonic() async {
    var mnemonic = widget.mnemonic;

    logger.i("mnemonic:$mnemonic");

    if (mnemonic != null && mnemonic.isNotEmpty) {
      _resumeWords = mnemonic.split(" ");
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          actions: <Widget>[
            FlatButton(
              child: Text(
                '显示二维码',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        MnemonicQrcodePage(mnemonic: widget.mnemonic)));
              },
            ),
          ],
        ),
        body: Container(
          color: Colors.white,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      S.of(context).your_mnemonic,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      S.of(context).save_mnemonic_notice,
                      style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          new SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 10.0,
                              crossAxisSpacing: 10.0,
                              childAspectRatio: 3),
                      itemCount: _resumeWords.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: HexColor("#FFB7B7B7")),
                                borderRadius: BorderRadius.circular(12)),
                            child: Text("${index + 1} ${_resumeWords[index]}"));
                      }),
                  Container(
                    child: InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: widget.mnemonic));
                        UiUtil.toast(S.of(context).copyed);
                      },
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Icon(
                            ExtendsIconFont.copy_content,
                            color: Colors.blue,
                            size: 20,
                          ),
                          SizedBox(
                            width: 4.0,
                          ),
                          Text(
                            S.of(context).copy,
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          )
                        ],
                      ),
                    ),
                    padding: EdgeInsets.only(top: 24),
                  ),
                  SizedBox(
                    height: 32.0,
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(color: HexColor("#FFFAEAEC")),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 16.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(
                            Icons.warning,
                            color: Color(0xFFD0021B),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            S.of(context).save_mnemonic_safe_notice,
                            style: TextStyle(
                              color: Color(0xFFD0021B),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            softWrap: true,
                          ),
                        ),
                        SizedBox(
                          width: 16.0,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 32.0,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16, horizontal: 36),
                    constraints: BoxConstraints.expand(height: 48),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      disabledColor: Colors.grey[600],
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      disabledTextColor: Colors.white,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    BackupConfirmResumeWordPage(
                                        widget.wallet, widget.mnemonic)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              S.of(context).continue_text,
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
        ));
  }
}
