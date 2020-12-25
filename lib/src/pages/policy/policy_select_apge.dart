import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/pages/bio_auth/bio_auth_page.dart';
import 'package:titan/src/components/auth/auth_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/policy/policy_confirm_page.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';

class PolicySelectPage extends StatefulWidget {
  PolicySelectPage();

  @override
  State<StatefulWidget> createState() {
    return _PolicySelectPageState();
  }
}

class _PolicySelectPageState extends State<PolicySelectPage> {
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
        padding: const EdgeInsets.only(left: 16,),
        child: Container(
          height: 0.8,
          color: HexColor('#F8F8F8'),
        ),
      );
    }
    return Scaffold(
        appBar: BaseAppBar(
          baseTitle: S.of(context).user_policy,
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: <Widget>[
            _lineWidget(),

            _buildMenuBar(S.of(context).policy_wallet, '', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PolicyConfirmPage(
                            PolicyType.WALLET,
                            isShowConfirm: false,
                          )));
            }),
            _dividerWidget(),

            _buildMenuBar(S.of(context).policy_hswap, '', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PolicyConfirmPage(
                            PolicyType.DEX,
                            isShowConfirm: false,
                          )));
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
                style: TextStyle(
                    color: HexColor("#333333"),
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),
            Spacer(),
            Text(
              subTitle?.isNotEmpty ?? false ? subTitle : "",
              style: TextStyle(color: HexColor("#AAAAAA"), fontSize: 12),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 20, 14, 20),
              child: Image.asset(
                'res/drawable/me_account_bind_arrow.png',
                width: 7,
                height: 12,
              ),
            )
          ],
        ),
      ),
    ),
  );
}
