import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_save/image_save.dart';
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
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/click_oval_button.dart';

class MyEncryptedAddrPage extends StatefulWidget {
  @override
  BaseState<StatefulWidget> createState() {
    return _MyEncryptedAddrPageState();
  }
}

class _MyEncryptedAddrPageState extends BaseState<MyEncryptedAddrPage>
    with RouteAware {
  GlobalKey _qrImageBoundaryKey = GlobalKey();

  String _walletPubKey;
  WalletVo _activeWallet;
  String walletSecurePubKey;

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() {
    initWalletData();
  }

  @override
  void didPopNext() {
    setState(() {
      initWalletData();
    });
    super.didPushNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Application.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    Application.routeObserver.unsubscribe(this);
    super.dispose();
  }

  initWalletData() async {
    _activeWallet = WalletInheritedModel.of(context).activatedWallet;
    if (_activeWallet != null) {
      walletSecurePubKey =
          '${SecurePrefsKey.WALLET_P2P_PUB_KEY_PREFIX}${_activeWallet.wallet.getEthAccount().address}';
      var walletPubKey = await AppCache.secureGetValue(walletSecurePubKey);
      print("!!!!$walletPubKey");
      if (walletPubKey != null) {
        _walletPubKey = walletPubKey;
      }
      setState(() {});
    }
  }

  _activateWallet() async {
    var password = await UiUtil.showWalletPasswordDialogV2(
      context,
      _activeWallet.wallet,
    );
    if (password == null) {
      return;
    }
    try {
      _walletPubKey = await TitanPlugin.trustActiveEncrypt(
          password, _activeWallet.wallet.keystore.fileName);
      await AppCache.secureSaveValue(walletSecurePubKey, _walletPubKey);
      setState(() {});
    } catch (error) {
      LogUtil.toastException(error);
    }
  }

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
        body: _activeWallet != null
            ? _walletPubKey != null ? _pubKeyView() : _walletNotActivatedView()
            : _noActiveWalletView());
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
                      if (_walletPubKey.isNotEmpty) {
                        Clipboard.setData(ClipboardData(text: _walletPubKey));
                        Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text(
                          S.of(context).public_key_copied,
                        )));
                      }
                    },
                    child: GestureDetector(
                      child: Icon(Icons.content_copy,
                          size: 22, color: Colors.black45),
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
                  if (_walletPubKey.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: _walletPubKey));
                    Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(
                      S.of(context).public_key_copied,
                    )));
                  }
                },
                child: Row(children: <Widget>[
                  Flexible(
                      child: Text(_walletPubKey,
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
              data: _walletPubKey,
              backgroundColor: Colors.white,
              foregroundColor: Colors.grey[800],
              version: 6,
              size: 200,
            ),
          )),
        ),
        SizedBox(
          height: 36,
        ),
        Center(
          child: Row(
            children: <Widget>[
              Spacer(),
              ClickOvalButton(
                S.of(context).share,
                () {
                  share();
                },
                height: 40,
                width: 110,
                fontSize: 16,
              ),
              SizedBox(
                width: 32,
              ),
              InkWell(
                onTap: _saveQrImage,
                child: Text(
                  S.of(context).save_qr_code,
                  style: TextStyle(
                    color: HexColor('#FF1F81FF'),
                    fontSize: 15,
                  ),
                ),
              ),
              Spacer(),
            ],
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
                S.of(context).create_import_wallet_before_using_feature,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            height: 32,
          ),
          ClickOvalButton(S.of(context).go_setting, () {
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
                S.of(context).public_key_need_password,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            height: 32,
          ),
          ClickOvalButton(S.of(context).authorized, () {
            _activateWallet();
          })
        ],
      ),
    );
  }

  void share() async {
    //print("[my-encrypted] === share");

    try {
      RenderRepaintBoundary boundary =
          _qrImageBoundaryKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final path = 'qrcode.jpg';
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/$path').create();
      await file.writeAsBytes(pngBytes);
      //print("[my-encrypted] === share, path:$path, file:$file");
      if (Platform.isIOS) {
        await Share.file(
            S.of(context).share_qrcode, path, pngBytes, 'image/jpeg');
      } else {
        TitanPlugin.shareImage(path, S.of(context).share_qrcode);
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: S.of(context).share_fail);
    }
  }

  _saveQrImage() async {
    bool result = false;
    try {
      RenderRepaintBoundary boundary =
          _qrImageBoundaryKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      result = await ImageSave.saveImage(pngBytes, "png",
          albumName: 'titan_wallet_$_walletPubKey');
    } catch (e) {
      result = false;
    }
    Fluttertoast.showToast(
      msg: result ? S.of(context).save_success : S.of(context).save_fail,
    );
  }
}
