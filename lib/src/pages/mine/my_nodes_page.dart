import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/config/application.dart';
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
        body: ListView(
          children: [
            SizedBox(
              height: 16.0,
            ),
            Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  _buildMenuBar('Map3节点', '', () {
                    Application.router.navigateTo(context, Routes.map3node_my_page);
                  }),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      height: 1,
                      color: HexColor('#FFF2F2F2'),
                    ),
                  ),
                  _buildMenuBar('Atlas节点', '', () {
                    Application.router.navigateTo(context, Routes.atlas_my_node_page);
                  }),
                ],
              ),
            )
          ],
        ));
  }
}

Widget _buildMenuBar(String title, String subTitle, Function onTap) {
  return InkWell(
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
              style: TextStyle(color: HexColor("#333333"), fontSize: 15, fontWeight: FontWeight.w400),
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
  );
}
