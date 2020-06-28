import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/click_oval_button.dart';

class MyEncryptedAddrPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyEncryptedAddrPageState();
  }
}

class _MyEncryptedAddrPageState extends State<MyEncryptedAddrPage> {
  String _pubKey = "";
  String _pubKeyAutoRefreshTip = "";

  GlobalKey _qrImageBoundaryKey = GlobalKey();

  @override
  void initState() {
    queryData();
    super.initState();
  }

  void queryData() async {
    _pubKey = await TitanPlugin.getPublicKey();
    var expireTime = await TitanPlugin.getExpiredTime();
    _pubKeyAutoRefreshTip = getExpiredTimeShowTip(context, expireTime);
    setState(() {});
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
        body: Container(
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
                    Text(S.of(context).main_my_public_key,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        )),
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
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
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
            Padding(
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
            ),
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
        ));
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

      TitanPlugin.shareImage(path, S.of(context).share_qrcode);
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
