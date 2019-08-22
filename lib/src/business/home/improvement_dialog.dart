import 'dart:math';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/src/inject/injector.dart';
import 'package:titan/src/model/poi_interface.dart';
import 'package:titan/src/utils/encryption.dart';

import '../../global.dart';

class ImprovementDialog extends StatefulWidget {
  ImprovementDialog();

  @override
  State<StatefulWidget> createState() {
    return ImprovementDialogDialogState();
  }
}

class ImprovementDialogDialogState extends State<ImprovementDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Duration insetAnimationDuration = const Duration(milliseconds: 100);
    Curve insetAnimationCurve = Curves.decelerate;

    RoundedRectangleBorder _defaultDialogShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2.0)));

    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets + const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                color: Colors.white,
              ),
              child: buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '改进体验计划',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Container(
                  color: Colors.grey[100],
                  margin: EdgeInsets.only(top: 16),
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Html(
                        data: """
                            为了让您在使用Titan过程中有更好的用户体验，邀请您参加用户体验改进计划来帮助提升产品品质。查看详细
                            <b>
                              <a href="https://www.map3.network/titan/privacy_policy/">计划说明</a>
                            </b>
                            """,
                        padding: EdgeInsets.all(8.0),
                        onLinkTap: (url) {
                          print("Opening $url...");
                        },
                      ),
                      Text(
                        '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                        child: RaisedButton(
                          onPressed: onDisAgree,
                          child: Text(
                            '不参与',
                            style: TextStyle(fontSize: 16),
                          ),
                          color: Colors.black87,
                          splashColor: Colors.white10,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        child: RaisedButton(
                          onPressed: onAgree,
                          child: Text(
                            '参与计划',
                            style: TextStyle(fontSize: 16),
                          ),
                          color: Colors.black87,
                          splashColor: Colors.white10,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  String addressErrorStr;

  String validatePubAddress(String address) {
    return addressErrorStr;
  }

  void onAgree() async {
    _savePlanDialogChoose(true);
    Navigator.pop(context);
  }

  void onDisAgree() async {
    _savePlanDialogChoose(false);
    Navigator.pop(context);
  }

  void _savePlanDialogChoose(bool isAgree) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isAgreePlan', isAgree);
//    setState(() {});
//    _isNeedShowIntro();
  }
}
