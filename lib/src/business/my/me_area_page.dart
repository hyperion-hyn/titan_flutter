import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/app.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/my/app_area.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';

class MeAreaPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeAreaState();
  }
}

class _MeAreaState extends State<MeAreaPage> {
  @override
  void initState() {
    super.initState();
  }

  var selectedAppArea = currentAppArea;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          S.of(context).app_area_setting,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          InkWell(
            onTap: () {
              switchAppArea(selectedAppArea);
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: Alignment.centerRight,
              child: Text(
                S.of(context).confirm,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: ListView(padding: EdgeInsets.symmetric(horizontal: 0), children: <Widget>[
        SizedBox(
          height: 4,
        ),
        _buildInfoContainer(label: S.of(context).mainland_china, appArea: AppArea.MAINLAND_CHINA_AREA),
        _divider(),
        _buildInfoContainer(label: S.of(context).other_area, appArea: AppArea.OTHER_AREA),
        _divider(),
      ]),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1.0,
        color: HexColor('#D7D7D7'),
      ),
    );
  }

  Widget _buildInfoContainer({String label, AppArea appArea}) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedAppArea = appArea;
        });
      },
      child: Container(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 15, 13),
              child: Text(
                label,
                style: TextStyle(color: HexColor("#333333"), fontSize: 16),
              ),
            ),
            Spacer(),
            Visibility(
              visible: selectedAppArea.key == appArea.key,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 15, 15, 13),
                child: Icon(
                  Icons.check,
                  color: Colors.green,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void switchAppArea(AppArea appArea) {
    appAreaChange(appArea);
    setState(() {});
  }
}
