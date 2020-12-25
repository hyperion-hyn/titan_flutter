import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/pages/bio_auth/bio_auth_page.dart';
import 'package:titan/src/components/auth/auth_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';

class BioAuthOptionsPage extends StatefulWidget {
  final Wallet wallet;

  BioAuthOptionsPage(this.wallet);

  @override
  State<StatefulWidget> createState() {
    return _BioAuthOptionsPage();
  }
}

class _BioAuthOptionsPage extends State<BioAuthOptionsPage> {
  @override
  Widget build(BuildContext context) {
    Widget _lineWidget({double height = 5}) {
      return Container(
        height: height,
        color: HexColor('#F8F8F8'),
      );
    }

    Widget _dividerWidget() {
      return Padding(
        padding: const EdgeInsets.only(
          left: 16,
        ),
        child: Container(
          height: 0.8,
          color: HexColor('#F8F8F8'),
        ),
      );
    }

    return Scaffold(
        appBar: BaseAppBar(
          baseTitle: S.of(context).bio_auth,
        ),
        body: Column(
          children: <Widget>[
            _lineWidget(),
            _buildMenuBar(S.of(context).secret_free_payment, '', () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => BioAuthPage(widget.wallet, AuthType.pay)));
            }),
            _dividerWidget(),
            _buildMenuBar(S.of(context).exchange_bio_auth, '', () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => BioAuthPage(widget.wallet, AuthType.exchange)));
            }),
          ],
        ));
  }
}

Widget _buildMenuBar(String title, String subTitle, Function onTap) {
  return Material(
    child: InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                title?.isNotEmpty ?? false ? title : "",
                style: TextStyle(color: HexColor("#333333"), fontSize: 14, fontWeight: FontWeight.w400),
              ),
            ),
            Spacer(),
            Text(
              subTitle?.isNotEmpty ?? false ? subTitle : "",
              style: TextStyle(color: HexColor("#AAAAAA"), fontSize: 12),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 14, 20),
              child: Image.asset(
                'res/drawable/me_account_bind_arrow.png',
                width: 7,
                height: 12,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
