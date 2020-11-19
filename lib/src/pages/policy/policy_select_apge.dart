import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
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
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          title: Text(
            S.of(context).user_policy,
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            _buildMenuBar(S.of(context).policy_wallet, '', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PolicyConfirmPage(
                            PolicyType.WALLET,
                            isShowConfirm: false,
                          )));
            }),
            Divider(
              height: 1,
            ),
            _buildMenuBar(S.of(context).policy_hswap, '', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PolicyConfirmPage(
                            PolicyType.DEX,
                            isShowConfirm: false,
                          )));
            }),
            Divider(
              height: 1,
            ),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              ),
            ),
            Spacer(),
            Text(
              subTitle?.isNotEmpty ?? false ? subTitle : "",
              style: TextStyle(color: HexColor("#AAAAAA"), fontSize: 16),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 15, 14, 15),
              child: Icon(
                Icons.chevron_right,
                color: Colors.black54,
              ),
            )
          ],
        ),
      ),
    ),
  );
}
