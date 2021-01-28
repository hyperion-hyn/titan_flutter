import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/wallet/wallet_new_page/wallet_backup_confirm_seed_phrase_page_v2.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class WalletBackupShowSeedPhrasePageV2 extends StatefulWidget {
  final Wallet wallet;
  final String seedPhrase;

  WalletBackupShowSeedPhrasePageV2(
    this.wallet,
    this.seedPhrase,
  );

  @override
  State<StatefulWidget> createState() {
    return _BackupShowResumeWordState();
  }
}

class _BackupShowResumeWordState extends State<WalletBackupShowSeedPhrasePageV2> {
  List _seedPhrase = [];

  @override
  void initState() {
    getSeedPhrase();
    super.initState();
  }

  Future getSeedPhrase() async {
    var seedPhrase = widget.seedPhrase;

    if (seedPhrase != null && seedPhrase.isNotEmpty) {
      _seedPhrase = seedPhrase.split(" ");
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black)),
        body: Container(
          color: Colors.white,
          height: double.infinity,
          child: Column(
            children: [
              Expanded(
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
                        _header(),
                        _seedPhraseView(),
                        _reminder('妥善保管助记词至隔离网络的安全地方。'),
                        _reminder('请勿将助记词在联网环境下分享和存储，比如邮件、相册、社交应用等。'),
                        SizedBox(height: 64),
                      ],
                    ),
                  ),
                ),
              ),
              _bottomBtn(),
            ],
          ),
        ));
  }

  _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '备份助记词',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '请按顺序抄写助记词，确保备份正确。',
          style: TextStyle(
            color: Color(0xFF9B9B9B),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  _seedPhraseView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36.0),
      child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.2,
          ),
          itemCount: _seedPhrase.length,
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
            } else if (index == _seedPhrase.length - 1) {
              borderRadius = BorderRadius.only(
                bottomRight: Radius.circular(8),
              );
            } else if (index == _seedPhrase.length - 3) {
              borderRadius = BorderRadius.only(
                bottomLeft: Radius.circular(8),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: HexColor('#FFF6F6F6'),
                border: Border.all(color: HexColor("#FFDEDEDE"), width: 0.5),
                borderRadius: borderRadius,
              ),
              child: Stack(
                children: [
                  Align(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_seedPhrase[index]}',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
                      style: TextStyle(color: DefaultColors.color999, fontSize: 10),
                    ),
                    top: 4,
                    right: 4,
                  ),
                ],
              ),
            );
          }),
    );
  }

  _reminder(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 10),
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
                fontSize: 13,
                color: DefaultColors.color999,
              ),
            ),
          )
        ],
      ),
    );
  }

  _bottomBtn() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36.0, top: 22),
      child: ClickOvalButton(
        '已确认备份',
        () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WalletBackupConfirmSeedPhrasePageV2(
                  widget.wallet,
                  widget.seedPhrase,
                ),
              ));
        },
        width: 300,
        height: 46,
        btnColor: [
          HexColor("#F7D33D"),
          HexColor("#E7C01A"),
        ],
        fontSize: 14,
        fontColor: DefaultColors.color333,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
