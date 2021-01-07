import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_pickers/UIConfig.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:r_scan/r_scan.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/bio_auth/bio_auth_page.dart';
import 'package:titan/src/pages/market/exchange/exchange_auth_page.dart';
import 'package:titan/src/pages/policy/policy_confirm_page.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/auth_util.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
import 'package:titan/src/widget/keyboard/wallet_password_dialog.dart';

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

  static showErrorTopHint(BuildContext context, String message,
      {ErrorHintType errorHintType = ErrorHintType.ERROR}) {
    List<Color> backColors;
    if (errorHintType == ErrorHintType.ERROR) {
      backColors = [HexColor('#FFEB8686'), HexColor('#FFEB8686')];
    } else if (errorHintType == ErrorHintType.REMIND) {
      backColors = [HexColor('#F7D33D'), HexColor('#E7C01A')];
    }
    Flushbar(
      padding: EdgeInsets.symmetric(
        vertical: 20.0,
      ),
      backgroundGradient: LinearGradient(
        colors: backColors,
      ),
      icon: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Image.asset(
          'res/drawable/ic_warning_triangle.png',
          width: 18,
          height: 18,
          color: Colors.white,
        ),
      ),
      messageText: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 13.0,
            color: Colors.white,
          ),
        ),
      ),
      flushbarStyle: FlushbarStyle.GROUNDED,
      flushbarPosition: FlushbarPosition.TOP,
      duration:
          errorHintType == ErrorHintType.ERROR ? Duration(seconds: 5) : null,
    ).show(context);
  }

  static toast(String message) {
    Fluttertoast.showToast(
        msg: message,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        timeInSecForIosWeb: 3);
  }

  static String shortEthAddress(String address, {int limitLength = 9}) {
    if (address == null || address == "") {
      return "";
    }
    if (address.length < limitLength) {
      return address;
    }
    return address.substring(0, limitLength) +
        "..." +
        address.substring(address.length - limitLength, address.length);
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
  static Future<bool> showAlertView<T>(
    BuildContext context, {
    String title,
    Color titleColor,
    bool barrierDismissible = true,
    bool isShowCloseIcon = true,
    Widget contentItem,
    List<Widget> actions,
    String content,
    String boldContent = "",
    String suffixContent = "",
    String detail = "",
    TextStyle boldStyle,
    bool isInputValue = false,
  }) {
    return showDialog<bool>(
      barrierDismissible: barrierDismissible,
      // 传入 context
      context: context,
      // 构建 Dialog 的视图
      builder: (_) => AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets +
            const EdgeInsets.symmetric(horizontal: 36.0),
        duration: const Duration(milliseconds: 100),
        curve: Curves.decelerate,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              //alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Stack(
                children: <Widget>[
                  isShowCloseIcon
                      ? Positioned(
                          right: 10,
                          top: 10,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(_, false),
                            child: Image.asset(
                              "res/drawable/map3_node_close.png",
                              width: 18,
                              height: 18,
                              color: Colors.black,
                            ),
                          ),
                        )
                      : Container(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(title,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: titleColor ?? HexColor("#333333"),
                                decoration: TextDecoration.none)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 16,
                            left: 24,
                            right: 24,
                            bottom: (contentItem != null || detail.isNotEmpty)
                                ? 0
                                : 18),
                        child: RichText(
                            text: TextSpan(
                                text: content,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: HexColor("#333333"),
                                    height: 1.8),
                                children: [
                              TextSpan(
                                text: boldContent,
                                style: boldStyle ??
                                    TextStyle(
                                        fontSize: 14,
                                        color: HexColor("#FF4C3B"),
                                        height: 1.8),
                              ),
                              TextSpan(
                                text: suffixContent,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: HexColor("#333333"),
                                    height: 1.8),
                              ),
                            ])),
                      ),
                      if (contentItem != null) contentItem,
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
                        padding: EdgeInsets.only(top: 18, bottom: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: actions,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            if (isInputValue)
              SizedBox(
                height: 120,
              ),
          ],
        ),
      ),
    );
  }

  // alertView
  static Future<bool> showAlertViewNew<T>(
    BuildContext context, {
    List<Widget> actions,
    Widget contentWidget,
    bool barrierDismissible = true,
    bool isShowCloseIcon = true,
    bool isShowBottom = false,
    Color barrierColor,
  }) {
    return showDialog<bool>(
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      // 传入 context
      context: context,
      // 构建 Dialog 的视图
      builder: (_) => AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets +
            const EdgeInsets.symmetric(horizontal: 36.0),
        duration: const Duration(milliseconds: 100),
        curve: Curves.decelerate,
        child: Column(
          mainAxisAlignment:
              isShowBottom ? MainAxisAlignment.end : MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: isShowBottom ? 65 : 0),
              //alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[200],
                    blurRadius: 1.0,
                  ),
                ],
              ),
              child: Stack(
                children: <Widget>[
                  isShowCloseIcon
                      ? Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context, false),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Image.asset(
                                "res/drawable/map3_node_close.png",
                                width: 18,
                                height: 18,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Column(
                    children: <Widget>[
                      contentWidget,
                      Padding(
                        padding: EdgeInsets.only(top: 18, bottom: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: actions,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<T> showDialogWidget<T>(
    BuildContext context, {
    Widget title,
    Widget content,
    List<Widget> actions,
  }) {
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

  static Future<bool> showRequestLocationAuthDialog<T>(
      BuildContext context, bool isServiceTurnOff) {
    return showDialogs<T>(
      context: context,
      title: isServiceTurnOff == true
          ? S.of(context).open_location_service
          : S.of(context).require_location,
      content: isServiceTurnOff == true
          ? S.of(context).open_location_service_message
          : S.of(context).require_location_message,
      func: () => openSettingLocation(isServiceTurnOff),
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

  static Future<bool> showDialogs<T>({
    BuildContext context,
    String title,
    String content,
    Function func,
    String ok = '',
  }) {
    return UiUtil.showAlertView(
      context,
      title: title,
      actions: [
        ClickOvalButton(
          S.of(context).cancel,
          () {
            Navigator.pop(context);
          },
          width: 115,
          height: 36,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          fontColor: DefaultColors.color333,
          btnColor: [Colors.transparent],
        ),
        SizedBox(
          width: 20,
        ),
        ClickOvalButton(
          ok.isNotEmpty ? ok : S.of(context).setting,
          () {
            func();
            Navigator.pop(context);
          },
          width: 115,
          height: 36,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ],
      content: content,
    );
  }

  static bool isIPhoneX(BuildContext context) {
    if (Platform.isIOS) {
      return MediaQuery.of(context).padding.bottom > 0;
    }
    return false;
  }

  static Future<T> showDecryptDialog<T>(
    BuildContext context,
    Function onClick,
  ) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            )),
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  S.of(context).receive_an_encrypted_message,
                  textAlign: TextAlign.center,
                  style: TextStyle(),
                ),
              ),
            ),
            content: Wrap(
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  height: 32,
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        child: Center(
                          child: InkWell(
                            child: Text(
                              S.of(context).cancel,
                              style: TextStyle(
                                color: HexColor('#FF999999'),
                              ),
                            ),
                            onTap: () async {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 13,
                    ),
                    Expanded(
                      child: ClickOvalButton(
                        S.of(context).open,
                        () async {
                          onClick();
                        },
                        height: 45,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                )
              ],
            ),
          );
        });
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
    Wallet wallet, {
    String dialogTitle,
    AuthType authType = AuthType.pay,
  }) async {
    CheckPwdValid onCheckPwdValid = (walletPwd) {
      return WalletUtil.checkPwdValid(
        context,
        wallet,
        walletPwd,
      );
    };

    var authConfig = await AuthUtil.getAuthConfigByWallet(
      wallet,
      authType: authType,
    );

    if (AuthUtil.bioAuthEnabled(authConfig)) {
      ///Bio-auth is expired, ask for pwd with password dialog.
      if (AuthUtil.bioAuthExpired(authConfig)) {
        Fluttertoast.showToast(msg: S.of(context).bio_auth_expired_hint);
        var pwd = await showPasswordDialog(
          context,
          wallet,
          onCheckPwdValid: onCheckPwdValid,
          authType: authType,
        );

        if (pwd != null) {
          ///Update last bio-auth time if pwd is correct
          if (await onCheckPwdValid(pwd)) {
            authConfig.lastBioAuthTime = DateTime.now().millisecondsSinceEpoch;
            AuthUtil.saveAuthConfig(
              authConfig,
              wallet,
              authType: authType,
            );
          }

          return pwd;
        }
      } else {
        ////BioAuth is not expired, check the password from disk is correct
        var bioAuthResult = await AuthUtil.bioAuth(
          context,
          AuthUtil.currentBioMetricType(authConfig),
        );

        if (bioAuthResult != null && bioAuthResult) {
          String pwd = await WalletUtil.getPwdFromSecureStorage(
            context,
            wallet,
          );

          ///Check pwd from SecureStorage
          if (await onCheckPwdValid(pwd)) {
            return pwd;
          }
        }
      }
    }

    ///Bio-auth not working, use default password dialog
    var pwd = await UiUtil.showPasswordDialog(
      context,
      wallet,
      onCheckPwdValid: onCheckPwdValid,
      dialogTitle: dialogTitle,
      authType: authType,
    );
    return pwd;
  }

  static Future<String> showPasswordDialog(
    BuildContext context,
    Wallet wallet, {
    @required CheckPwdValid onCheckPwdValid,
    bool isShowBioAuthIcon = true,
    String dialogTitle,
    AuthType authType = AuthType.pay,
  }) async {
    var useDigits = await WalletUtil.checkUseDigitsPwd(
      wallet,
    );

    if (useDigits) {
      return showDialog(
          context: context,
          barrierDismissible: false,
          child: WalletPasswordDialog(
            title: dialogTitle ?? S.of(context).input_payment_password,
            checkPwdValid: onCheckPwdValid,
            isShowBioAuthIcon: isShowBioAuthIcon,
            wallet: wallet,
            authType: authType,
          ));
    } else {
      var pwd = await showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          builder: (BuildContext context) {
            return EnterWalletPasswordWidget(
              isShowBioAuthIcon: isShowBioAuthIcon,
              wallet: wallet,
              authType: authType,
              onPwdSubmitted: onCheckPwdValid,
            );
          });
      var result = await onCheckPwdValid(pwd);
      if (result) {
        return pwd;
      } else {
        return null;
      }
    }
  }

  ///Double-check password dialog
  static Future<String> showDoubleCheckPwdDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        child: WalletPasswordDialog(
          checkPwdValid: null,
          isDoubleCheck: true,
        ));
  }

//  static showSetBioAuthDialog(
//    BuildContext context,
//    String title,
//    Wallet activeWallet,
//    String pwd,
//  ) async {
//    if (AuthInheritedModel.of(context).showSetBioAuthDialog) {
//      var result = await showDialog(
//          context: context,
//          barrierDismissible: false,
//          child: SetBioAuthDialog(
//              AuthInheritedModel.of(context).currentBioMetricType, title));
//      if (result != null && result) {
//        AppCache.secureSaveValue(
//          '${SecurePrefsKey.WALLET_PWD_KEY_PREFIX}${activeWallet.getEthAccount().address}',
//          pwd,
//        );
//        BlocProvider.of<AuthBloc>(context).add(SetBioAuthEvent(
//          true,
//          activeWallet.getEthAccount().address,
//        ));
//        Future.delayed(Duration(milliseconds: 3));
//        Fluttertoast.showToast(
//          msg: '成功开启生物识别',
//          gravity: ToastGravity.CENTER,
//          toastLength: Toast.LENGTH_LONG,
//        );
//      } else {
//        Fluttertoast.showToast(
//          msg: '生物识别未开启',
//          gravity: ToastGravity.CENTER,
//          toastLength: Toast.LENGTH_LONG,
//        );
//      }
//    }
//  }

  static showConfirmPolicyDialog(
    BuildContext context,
    PolicyType policyType, {
    bool isShowConfirm = true,
  }) {
    var height = MediaQuery.of(context).size.height - 80;
    showDialog(
      context: context,
      builder: (_) => Material(
        type: MaterialType.transparency,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: PolicyConfirmPage(
                policyType,
                isShowConfirm: isShowConfirm,
                isDialog: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static showHintToast(BuildContext context, Widget icon, msg) {
    Widget widget = Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          width: 150,
          height: 150,
          color: HexColor('#4D000000'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Spacer(),
              icon,
              SizedBox(
                height: 16,
              ),
              Text(
                msg,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white),
              ),
              Spacer()
            ],
          ),
        ),
      ),
    );
    showToastWidget(
      widget,
      duration: Duration(seconds: 1),
      onDismiss: () {},
    );
  }

  static Future showLoadingDialog(
      BuildContext context, msg, Function createContext) async {
    Widget widget = Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          width: 150,
          height: 150,
          color: HexColor('#4D000000'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Spacer(),
              SizedBox(
                height: 32,
                width: 32,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 1.5,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                msg,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                    decoration: TextDecoration.none),
              ),
              Spacer()
            ],
          ),
        ),
      ),
    );
    await showDialog<bool>(
        barrierColor: Colors.transparent,
        barrierDismissible: false,
        // 传入 context
        context: context,
        // 构建 Dialog 的视图
        builder: (_) => Builder(builder: (context) {
              createContext(context);
              return WillPopScope(
                  onWillPop: () {
                    Navigator.pop(context, true);
                    return;
                  },
                  child: widget);
            }));
  }

  static Future<T> showExchangeAuthAgainDialog<T>(
    BuildContext context, {
    Widget title,
    Widget content,
    List<Widget> actions,
  }) {
    return showDialogWidget(
      context,
      title: Text(S.of(context).exchange_auth),
      content: Text(S.of(context).exchange_ask_auth_again),
      actions: [
        FlatButton(
          child: Text(S.of(context).cancel),
          onPressed: () => Navigator.pop(context),
        ),
        FlatButton(
          child: Text(S.of(context).confirm),
          onPressed: () {
            Navigator.pop(context);

            ///
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ExchangeAuthPage()));
          },
        ),
      ],
    );
  }

  static Future<T> showDialogsNoCallback<T>(
      BuildContext context, String title, String content,
      {String confirm = ""}) {
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
          child: Text(confirm.isNotEmpty ? confirm : S.of(context).setting),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }

  static Future<bool> showScanImagePickerSheet(BuildContext context,
      {ImageCallback callback}) async {
    return await showModalBottomSheet(
        context: context,
        builder: (BuildContext dialogContext) {
          return Wrap(
            children: <Widget>[
              ListTile(
                title: Text(S.of(context).camera_scan,
                    textAlign: TextAlign.center),
                onTap: () async {
                  Future.delayed(Duration(milliseconds: 500), () {
                    Navigator.pop(dialogContext, true);
                  });

                  String mnemonicWords = await BarcodeScanner.scan();
                  callback(mnemonicWords);
                },
              ),
              ListTile(
                title: Text(S.of(context).import_from_album,
                    textAlign: TextAlign.center),
                onTap: () async {
                  Future.delayed(Duration(milliseconds: 500), () {
                    Navigator.pop(dialogContext, true);
                  });

                  var tempListImagePaths = await ImagePickers.pickerPaths(
                    galleryMode: GalleryMode.image,
                    selectCount: 1,
                    showCamera: true,
                    cropConfig: null,
                    compressSize: 500,
                    uiConfig: UIConfig(uiThemeColor: Color(0xff0f95b0)),
                  );
                  if (tempListImagePaths != null &&
                      tempListImagePaths.length == 1) {
                    RScanResult mnemonicWords =
                        await RScan.scanImagePath(tempListImagePaths[0].path);
                    String mnemonicWord = mnemonicWords?.message;
                    callback(mnemonicWord);
                  }
                },
              ),
              ListTile(
                title: Text(S.of(context).cancel, textAlign: TextAlign.center),
                onTap: () {
                  Navigator.pop(dialogContext, false);
                },
              ),
            ],
          );
        });
  }

  static Future<bool> showIconImagePickerSheet(BuildContext context,
      {ImageCallback callback}) async {
    return await showModalBottomSheet(
        context: context,
        builder: (BuildContext dialogContext) {
          return Wrap(
            children: <Widget>[
              ListTile(
                title: Text('拍照', textAlign: TextAlign.center),
                onTap: () async {
                  Future.delayed(Duration(milliseconds: 500), () {
                    Navigator.pop(dialogContext, true);
                  });

                  callback('');
                },
              ),
              ListTile(
                title: Text(S.of(context).import_from_album,
                    textAlign: TextAlign.center),
                onTap: () async {
                  Future.delayed(Duration(milliseconds: 500), () {
                    Navigator.pop(dialogContext, true);
                  });

                  var tempListImagePaths = await ImagePickers.pickerPaths(
                    galleryMode: GalleryMode.image,
                    selectCount: 1,
                    showCamera: true,
                    cropConfig: null,
                    compressSize: 500,
                    uiConfig: UIConfig(uiThemeColor: Color(0xff0f95b0)),
                  );
                  if (tempListImagePaths != null &&
                      tempListImagePaths.length == 1) {
                    var path = tempListImagePaths[0].path;
                    callback(path);
                  }
                },
              ),
              ListTile(
                title: Text(S.of(context).cancel, textAlign: TextAlign.center),
                onTap: () {
                  Navigator.pop(dialogContext, false);
                },
              ),
            ],
          );
        });
  }
}

typedef ImageCallback = void Function(String text);

void callLater(FrameCallback callback) {
  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    callback(timeStamp);
  });
}

enum ErrorHintType { ERROR, REMIND }
