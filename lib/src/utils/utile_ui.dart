import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

class UiUtil {
  static double getRenderObjectHeight(GlobalKey key) {
    RenderBox renderBox = key.currentContext?.findRenderObject();
    var h = renderBox?.size?.height ?? 0;
    return h;
  }

  static void showSnackBar(BuildContext context, String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
      action: SnackBarAction(
        label: S.of(context).close,
        onPressed: () {
          Scaffold.of(context).hideCurrentSnackBar();
        },
      ),
      content: Text(message),
    ));
  }

  static toast(String message) {
    Fluttertoast.showToast(msg: message, backgroundColor: Colors.black, textColor: Colors.white);
  }

  static String shortEthAddress(String address, {int limitLength = 9}) {
    if (address == null || address == "") {
      return "";
    }
    if (address.length < limitLength) {
      return address;
    }
    return address.substring(0, limitLength) + "..." + address.substring(address.length - limitLength, address.length);
  }

  static String shortString(String address, {int limitLength = 9}) {
    if (address == null || address == "") {
      return "";
    }
    if (address.length < limitLength) {
      return address;
    }
    return address.substring(0, limitLength) + "...";
  }

  static String shortEmail(String email) {
    if (email == null || email == "") {
      return "";
    }

    int atIconIndex = email.indexOf("@");
    if (atIconIndex < 3) {
      return email;
    }
    return email.substring(0, 3) + "*" + email.substring(atIconIndex);
  }

  // alertView
  static Future<T> showDialogWidget<T>(BuildContext context, {Widget title, Widget content, List<Widget> actions}) {
    return showDialog<T>(
      context: context,
      builder: (context) {
        return Platform.isIOS
            ? CupertinoAlertDialog(
                title: title,
                content: content,
                actions: actions,
              )
            : AlertDialog(
                title: title,
                content: content,
                actions: actions,
              );
      },
    );
  }

  static Future<T> showConfirmDialogWidget<T>(BuildContext context, {Widget content, List<Widget> actions}) {
    return showDialog<T>(
      context: context,
      builder: (context) {
        return Platform.isIOS
            ? CupertinoAlertDialog(
                title: Text(S.of(context).tips),
                content: content,
                actions: actions,
              )
            : AlertDialog(
                title: content,
                actions: actions,
              );
      },
    );
  }

  static void showConfirmDialog(BuildContext context, {String content}) {
    showConfirmDialogWidget(context, content: Text(content), actions: <Widget>[
      FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(S.of(context).confirm))
    ]);
  }

  static Future<T> showRequestLocationAuthDialog<T>(BuildContext context, bool isServiceTurnOff) {
    return showDialogs<T>(
      context,
      isServiceTurnOff == true ? S.of(context).open_location_service : S.of(context).require_location,
      isServiceTurnOff == true ? S.of(context).open_location_service_message : S.of(context).require_location_message,
      () => openSettingLocation(isServiceTurnOff),
    );
  }

  static void openSettingLocation(bool isServiceTurnOff) {
    if (Platform.isIOS) {
      openAppSettings();
    } else {
      if (isServiceTurnOff == true) {
        AndroidIntent intent = new AndroidIntent(
          action: 'action_location_source_settings',
        );
        intent.launch();
      } else {
        openAppSettings();
      }
    }
  }

  static Future<T> showDialogs<T>(BuildContext context, String title, String content, Function func) {
    return showDialogWidget<T>(
      context,
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        FlatButton(
          child: Text(S.of(context).cancel),
          onPressed: () => Navigator.pop(context),
        ),
        FlatButton(
          child: Text(S.of(context).setting),
          onPressed: () {
            func();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }


  static bool isIPhoneX(BuildContext context) {
    if (Platform.isIOS) {
      return MediaQuery.of(context).padding.bottom > 0;
    }
    return false;
  }

  static Future<T> showAlertView<T>(
      BuildContext context,
      {String title,
        List<Widget> actions,
        String content,
        String detail = "",
        String boldContent = "",
        String suffixContent = ""}) {
    showDialog<T>(
      // 传入 context
      context: context,
      // 构建 Dialog 的视图
      builder: (_) => Padding(
        padding: EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              //alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    right: 10,
                    top: 10,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(_),
                      child: Image.asset(
                        "res/drawable/map3_node_close.png",
                        width: 18,
                        height: 18,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(title,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: HexColor("#333333"),
                                decoration: TextDecoration.none)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 24, left: 24, right: 24),
                        child: RichText(
                            text: TextSpan(
                                text: content,
                                style: TextStyle(fontSize: 15, color: HexColor("#333333"), height: 1.8),
                                children: [
                                  TextSpan(
                                    text: boldContent,
                                    style: TextStyle(fontSize: 15, color: HexColor("#FF4C3B"), height: 1.8),
                                  ),
                                  TextSpan(
                                    text: suffixContent,
                                    style: TextStyle(fontSize: 15, color: HexColor("#333333"), height: 1.8),
                                  ),
                                ])),
                      ),
                      if (detail.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 6, left: 24, right: 24),
                          child: Text(detail,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  color: HexColor("#999999"),
                                  height: 1.8,
                                  decoration: TextDecoration.none)),
                        ),
                      Padding(
                        padding: EdgeInsets.only(top: 15, bottom: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: actions,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}

void callLater(FrameCallback callback) {
  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    callback(timeStamp);
  });
}
