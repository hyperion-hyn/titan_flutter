import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/widget/progress_dialog_mask/bloc/bloc.dart';
import 'package:titan/src/widget/progress_dialog_mask/progress_mask_dialog.dart';

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

  static ProgressMaskDialogBloc showMaskDialog(BuildContext context) {
    var _progressMaskDialogBloc = ProgressMaskDialogBloc();
    showDialog(
        context: context,
        builder: (context) {
          return ProgressMaskDialog(
            bloc: _progressMaskDialogBloc,
          );
        });
    return _progressMaskDialogBloc;
  }

  static toast(String message) {
    Fluttertoast.showToast(msg: message, backgroundColor: Colors.black, textColor: Colors.white);
  }

  static String shortEthAddress(String address) {
    if (address == null || address == "") {
      return "";
    }
    if (address.length < 9) {
      return address;
    }
    return address.substring(0, 9) + "..." + address.substring(address.length - 9, address.length);
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

  static Future<T> showDialogs<T>(BuildContext context, String title, String content, Function func, {String confirm = ""}) {
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
          child: Text(confirm.isNotEmpty?confirm:S.of(context).setting),
          onPressed: () {
            func();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  static Future<T> showDialogsNoCallback<T>(BuildContext context, String title, String content, {String confirm = ""}) {
    return showDialogWidget<T>(
      context,
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        FlatButton(
          child: Text(S.of(context).cancel),
          onPressed: () => Navigator.pop(context, false),
        ),
        FlatButton(
          child: Text(confirm.isNotEmpty?confirm:S.of(context).setting),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }

}

void callLater(FrameCallback callback) {
  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    callback(timeStamp);
  });
}
