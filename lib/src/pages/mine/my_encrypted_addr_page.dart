import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/click_oval_button.dart';

class MyEncryptedAddrPage extends StatefulWidget {
  @override
  BaseState<StatefulWidget> createState() {
    return _MyEncryptedAddrPageState();
  }
}

class _MyEncryptedAddrPageState extends BaseState<MyEncryptedAddrPage> {
  String _pubKey = "";
  String _pubKeyAutoRefreshTip = "";

  GlobalKey _qrImageBoundaryKey = GlobalKey();

//  bool _walletActivated = false;
//  String _walletPubKey = '';
//  WalletVo _activeWallet;

  @override
  void initState() {
    super.initState();
    queryData();
  }

//  @override
//  void onCreated() {
//    _activeWallet = WalletInheritedModel.of(context).activatedWallet;
//    if (_activeWallet != null) {
//      _getCurrentWalletPubKey();
//    }
//  }

  void queryData() async {
    _pubKey = await TitanPlugin.getPublicKey();
    var expireTime = await TitanPlugin.getExpiredTime();
    _pubKeyAutoRefreshTip = getExpiredTimeShowTip(context, expireTime);
    setState(() {});
  }

  // _getCurrentWalletPubKey() async {
  //      var walletPubKey = await AppCache.getValue(
//          '${PrefsKey.WALLET_PUB_KEY_PREFIX_KEY}${_activatedWalletVo.getEthAccount().address}');
//    var walletPubKey =
//        await AppCache.getValue(PrefsKey.ACTIVATED_WALLET_FILE_NAME);
//    _walletActivated = walletPubKey != null;
//    if (walletPubKey != null) {
//      _walletPubKey = walletPubKey;
//      _walletActivated = true;
//    }
//
//    setState(() {});
//  }

//  _activateWallet() async {
//    ///Get pub key from TitanPlugin here
//    ///
//    var result = await AppCache.saveValue<String>(
//        '${PrefsKey.WALLET_PUB_KEY_PREFIX_KEY}${_activeWallet.wallet.getEthAccount().address}',
//        'PubKey');
//    setState(() {
//      _walletActivated = result;
//    });
//    if (!result) {
//      Fluttertoast.showToast(msg: '授权失败');
//    }
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            S.of(context).key_manager_title,
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: _pubKeyView());
  }

  _pubKeyView() {
    return Container(
      color: Colors.white,
      child: ListView(children: <Widget>[
        SizedBox(
          height: 16,
        ),
        Stack(
          children: <Widget>[
            Center(
                child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Container(
                  width: 180,
                  child: Text(S.of(context).main_my_public_key,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      )),
                ),
              ],
            )),
            Positioned(
              right: 64,
              child: Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      if (_pubKey.isNotEmpty) {
                        Clipboard.setData(ClipboardData(text: _pubKey));
                        Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text(
                          S.of(context).public_key_copied,
                        )));
                      }
                    },
                    child: GestureDetector(
                      child: Icon(Icons.content_copy, size: 22, color: Colors.black45),
                    ),
                  );
                },
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
          child: Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                onTap: () {
                  if (_pubKey.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: _pubKey));
                    Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(
                      S.of(context).public_key_copied,
                    )));
                  }
                },
                child: Row(children: <Widget>[
                  Flexible(
                      child: Text(_pubKey,
                          style: TextStyle(
                            color: HexColor('#FF999999'),
                            height: 2.0,
                          ))),
                ]),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Center(
              child: RepaintBoundary(
            key: _qrImageBoundaryKey,
            child: QrImage(
              data: _pubKey,
              backgroundColor: Colors.white,
              foregroundColor: Colors.grey[800],
              version: 6,
              size: 200,
            ),
          )),
        ),
        /*Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  _pubKeyAutoRefreshTip,
                  style: TextStyle(color: Colors.black54),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: InkWell(
                    onTap: () => showRefreshDialog(context),
                    child: Text(
                      S.of(context).manually_refresh,
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                )
              ]),
        ),*/
        SizedBox(
          height: 36,
        ),
        Center(
          child: ClickOvalButton(
            S.of(context).share,
            () {
              share();
            },
            height: 40,
            width: 110,
            fontSize: 16,
          ),
        ),
      ]),
    );
  }

  _noActiveWalletView() {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 32,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              'res/drawable/safe_lock.png',
              width: 100,
              height: 100,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Container(
              width: 200,
              child: Text(
                '您当前还没有钱包，请先创建或导入钱包再使用此功能',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            height: 32,
          ),
          ClickOvalButton('去设置', () {
            Application.router.navigateTo(context, Routes.wallet_manager);
          })
        ],
      ),
    );
  }

  _walletNotActivatedView() {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 32,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              'res/drawable/safe_lock.png',
              width: 100,
              height: 100,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Container(
              width: 200,
              child: Text(
                '获取公钥需要输入密码授权',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            height: 32,
          ),
          ClickOvalButton('授权', () {
            // _activateWallet();
          })
        ],
      ),
    );
  }

  void showRefreshDialog(context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(S.of(context).tips),
            content: Text(S.of(context).refresh_keypaire_message),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).cancel)),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    genNewKeys();
                  },
                  child: Text(S.of(context).confirm))
            ],
          );
        },
        barrierDismissible: true);
  }

  void genNewKeys() {
    Future.delayed(const Duration(milliseconds: 200)).then((data) {
      return TitanPlugin.genKeyPair();
    }).then((key) {
      _pubKey = key;
      return TitanPlugin.getExpiredTime();
    }).then((expireTime) {
      var tip = getExpiredTimeShowTip(context, expireTime);
      _pubKeyAutoRefreshTip = tip;
      setState(() {});
    });
  }

  void share() async {
    //print("[my-encrypted] === share");

    try {
      RenderRepaintBoundary boundary = _qrImageBoundaryKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final path = 'qrcode.jpg';
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/$path').create();
      await file.writeAsBytes(pngBytes);
      //print("[my-encrypted] === share, path:$path, file:$file");
      if (Platform.isIOS) {
        await Share.file(S.of(context).share_qrcode, path, pngBytes, 'image/jpeg');
      } else {
        TitanPlugin.shareImage(path, S.of(context).share_qrcode);
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: S.of(context).share_fail);
    }

//    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
//    print(permission);
//    if (permission != PermissionStatus.granted) {
//      Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
//    }
//
//    ServiceStatus serviceStatus = await PermissionHandler().checkServiceStatus(PermissionGroup.storage);
//    print(serviceStatus);
//
//    PermissionHandler().openAppSettings();
//    var canInstall = await TitanPlugin.requestInstallUnknownSourceSetting();
//    print(canInstall);
  }
}
