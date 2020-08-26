import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/map3page/my_map3_contracts_page.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/routes/routes.dart';

class MyNodesPage extends StatefulWidget {
  MyNodesPage();

  @override
  State<StatefulWidget> createState() {
    return _MyNodesPageState();
  }
}

class _MyNodesPageState extends State<MyNodesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BaseAppBar(
          baseTitle: '我的节点',
        ),
        body: Column(
          children: <Widget>[
            SizedBox(
              height: 16,
            ),
            Divider(
              height: 1,
            ),
            _buildMenuBar('Map3节点', '', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyContractsPage(),
                ),
              );
            }),
            Divider(
              height: 1,
            ),
            _buildMenuBar('Atlas节点', '', () {
              Application.router.navigateTo(context, Routes.atlas_my_node_page);
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
