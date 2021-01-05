import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

// ignore: must_be_immutable
class CreateWalletBackupNoticePageV2 extends StatefulWidget {
  String walletName;
  String password;

  CreateWalletBackupNoticePageV2(this.walletName, this.password);

  @override
  State<StatefulWidget> createState() {
    return _CreateWalletBackupNoticePageV2State();
  }
}

class _CreateWalletBackupNoticePageV2State
    extends State<CreateWalletBackupNoticePageV2> {
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
                  '立即备份',
                  () {
                    _next();
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {},
                    child: Text(
                      '稍后备份',
                      style: TextStyle(
                        color: DefaultColors.primary,
                      ),
                    ),
                  ),
                )
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

  void _next() {
    var walletName = FluroConvertUtils.fluroCnParamsEncode(widget.walletName);
    Application.router.navigateTo(
        context,
        Routes.wallet_show_resume_word +
            '?walletName=$walletName&password=${widget.password}');
  }
}
