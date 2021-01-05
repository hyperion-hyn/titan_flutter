import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/pages/wallet/wallet_backup_confirm_resume_word_page.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/wallet/wallet_new_page/wallet_backup_confirm_resume_words_page_v2.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

import '../mnemonic_qrcode_page.dart';

class BackupShowResumeWordPageV2 extends StatefulWidget {
  final Wallet wallet;
  final String mnemonic;

  BackupShowResumeWordPageV2(this.wallet, this.mnemonic);

  @override
  State<StatefulWidget> createState() {
    return _BackupShowResumeWordState();
  }
}

class _BackupShowResumeWordState extends State<BackupShowResumeWordPageV2> {
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
          actions: <Widget>[],
        ),
        body: Container(
          color: Colors.white,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16.0,
              ),
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '备份助记词',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    '请按顺序抄写助记词，确保备份正确。',
                    style: TextStyle(
                      color: Color(0xFF9B9B9B),
                      fontSize: 14,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36.0),
                    child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            new SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2.2,
                        ),
                        itemCount: _resumeWords.length,
                        itemBuilder: (BuildContext context, int index) {
                          var borderRadius = BorderRadius.zero;
                          if (index == 0) {
                            borderRadius = BorderRadius.only(
                              topLeft: Radius.circular(8),
                            );
                          } else if (index == 2) {
                            borderRadius = BorderRadius.only(
                              topRight: Radius.circular(8),
                            );
                          } else if (index == _resumeWords.length - 1) {
                            borderRadius = BorderRadius.only(
                              bottomRight: Radius.circular(8),
                            );
                          } else if (index == _resumeWords.length - 3) {
                            borderRadius = BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                            );
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: HexColor('#FFF6F6F6'),
                              border: Border.all(
                                color: HexColor("#FFDEDEDE"),
                                width: 0.5,
                              ),
                              borderRadius: borderRadius,
                            ),
                            child: Stack(
                              children: [
                                Align(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${_resumeWords[index]}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                ),
                                Positioned(
                                  child: Text(
                                    "${index + 1}",
                                    style: TextStyle(
                                        color: DefaultColors.color999,
                                        fontSize: 10),
                                  ),
                                  top: 4,
                                  right: 4,
                                ),
                              ],
                            ),
                          );
                        }),
                  ),
                  _reminder('妥善保管助记词至隔离网络的安全地方'),
                  _reminder('请勿将助记词在联网环境下分享和存储，比如邮件、相册、社交应用等。'),
                  SizedBox(
                    height: 64,
                  ),
                  Center(
                    child: ClickOvalButton(
                      '已确认备份',
                      () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BackupConfirmResumeWordPageV2(
                                widget.wallet,
                                widget.mnemonic,
                              ),
                            ));
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
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget rowTipsItem(
    String title, {
    double top = 8,
    String subTitle = "",
    GestureTapCallback onTap,
  }) {
    var _nodeWidget = Padding(
      padding: const EdgeInsets.only(right: 10, top: 10),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DefaultColors.color999,
            border: Border.all(color: DefaultColors.color999, width: 1.0)),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _nodeWidget,
          Expanded(
              child: InkWell(
            onTap: onTap,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: subTitle,
                    style: TextStyle(color: HexColor("#1F81FF"), fontSize: 12),
                  )
                ],
                text: title,
                style: TextStyle(
                    height: 1.8, color: DefaultColors.color999, fontSize: 12),
              ),
            ),
          )),
        ],
      ),
    );
  }

  _reminder(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DefaultColors.color999,
                  border:
                      Border.all(color: DefaultColors.color999, width: 1.0)),
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
      ),
    );
  }
}
