import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/auth/auth_component.dart';
import 'package:titan/src/components/auth/bloc/auth_bloc.dart';
import 'package:titan/src/components/auth/bloc/auth_event.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/widget/auth_dialog/SetBioAuthDialog.dart';
import 'package:titan/src/widget/auth_dialog/bio_auth_dialog.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
import 'package:titan/src/widget/wallet_password_dialog.dart';

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
    Fluttertoast.showToast(
        msg: message, backgroundColor: Colors.black, textColor: Colors.white);
  }

  static String shortEthAddress(String address) {
    if (address == null || address == "") {
      return "";
    }
    if (address.length < 9) {
      return address;
    }
    return address.substring(0, 9) +
        "..." +
        address.substring(address.length - 9, address.length);
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
  static Future<T> showDialogWidget<T>(BuildContext context,
      {Widget title, Widget content, List<Widget> actions}) {
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

  static Future<T> showConfirmDialogWidget<T>(BuildContext context,
      {Widget content, List<Widget> actions}) {
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

  static Future<T> showRequestLocationAuthDialog<T>(
      BuildContext context, bool isServiceTurnOff) {
    return showDialogs<T>(
      context,
      isServiceTurnOff == true
          ? S.of(context).open_location_service
          : S.of(context).require_location,
      isServiceTurnOff == true
          ? S.of(context).open_location_service_message
          : S.of(context).require_location_message,
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

  static Future<T> showDialogs<T>(
      BuildContext context, String title, String content, Function func) {
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

//  static Future<String> showEnterPassWordBottomSheet(
//      BuildContext context) {
//    return showModalBottomSheet(
//        isScrollControlled: true,
//        context: context,
//        shape: RoundedRectangleBorder(
//          borderRadius: BorderRadius.circular(15.0),
//        ),
//        builder: (BuildContext context) {
//          return EnterWalletPasswordWidget();
//        });
//  }

  static Future<String> showWalletPasswordDialogV2(
    BuildContext context,
    Wallet activeWallet, {
    @required CheckPwdValid onCheckPwdValid,
  }) async {
//    if (AuthInheritedModel.of(context).bioAuthEnabled) {
//      ///Bio-auth is expired, ask for pwd with password dialog.
//      if (AuthInheritedModel.of(context).bioAuthExpired) {
//        var pwd = await showPasswordDialog(
//            context, activeWallet.getEthAccount().address,
//            onCheckPwdValid: onCheckPwdValid);
//
//        ///Check password from secureStorage is correct
//        var result = await WalletUtil.exportPrivateKey(
//          fileName: WalletInheritedModel.of(context)
//              .activatedWallet
//              .wallet
//              .keystore
//              .fileName,
//          password: pwd,
//        );
//        if (result != null) {
//          BlocProvider.of<AuthBloc>(context).add(
//            SetBioAuthEvent(true, activeWallet.getEthAccount().address),
//          );
//        }
//        return pwd;
//      } else {
//        ///BioAuth is not expired, check the password from disk is correct
//        bool bioAuthResult = await showDialog(
//          context: context,
//          child: BioAuthDialog(),
//        );
//        if (bioAuthResult != null && bioAuthResult) {
//          String pwd = await WalletUtil.getPwdFromStorage(
//            context,
//            activeWallet.getEthAccount().address,
//          );
//          print('getPwdFromStorage: $pwd');
//          if (pwd != null) {
//            return pwd;
//          }
//        }
//      }
//    }
    var pwd = await UiUtil.showPasswordDialog(
      context,
      activeWallet.getEthAccount().address,
      onCheckPwdValid: onCheckPwdValid,
    );
    return pwd;
  }

  static Future<String> showPasswordDialog(
    BuildContext context,
    String walletAddress, {
    @required CheckPwdValid onCheckPwdValid,
  }) async {
//    var useDigits = await WalletUtil.checkUseDigitsPwd(
//      walletAddress,
//    );
//
//    if (useDigits != null && useDigits) {
//      return showDialog(
//          context: context,
//          barrierDismissible: false,
//          child: WalletPasswordDialog(
//            title: '请输入钱包密码',
//            checkPwdValid: onCheckPwdValid,
//          ));
//    } else {
//      return showModalBottomSheet(
//          isScrollControlled: true,
//          context: context,
//          shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.circular(15.0),
//          ),
//          builder: (BuildContext context) {
//            return EnterWalletPasswordWidget();
//          });
//    }
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        builder: (BuildContext context) {
          return EnterWalletPasswordWidget();
        });
  }

  static showSetBioAuthDialog(
    BuildContext context,
    String title,
    Wallet activeWallet,
    String pwd,
  ) async {
    if (AuthInheritedModel.of(context).showSetBioAuthDialog) {
      var result = await showDialog(
          context: context,
          barrierDismissible: false,
          child: SetBioAuthDialog(
              AuthInheritedModel.of(context).currentBioMetricType, title));
      if (result != null && result) {
        AppCache.secureSaveValue(
          '${SecurePrefsKey.WALLET_PWD_KEY_PREFIX}${activeWallet.getEthAccount().address}',
          pwd,
        );
        BlocProvider.of<AuthBloc>(context).add(SetBioAuthEvent(
          true,
          activeWallet.getEthAccount().address,
        ));
        Future.delayed(Duration(milliseconds: 3));
        Fluttertoast.showToast(
          msg: '成功开启生物识别',
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG,
        );
      } else {
        Fluttertoast.showToast(
          msg: '生物识别未开启',
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    }
  }
}

void callLater(FrameCallback callback) {
  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    callback(timeStamp);
  });
}
