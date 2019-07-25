import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:path_provider/path_provider.dart';

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
    _pubKeyAutoRefreshTip = await TitanPlugin.getExpiredTimeShowTip();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('我的加密地址')),
        body: ListView(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Center(child: Text('加密地址（公钥）', style: TextStyle(fontSize: 20))),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    if (_pubKey.isNotEmpty) {
                      Clipboard.setData(ClipboardData(text: _pubKey));
                      Scaffold.of(context).showSnackBar(SnackBar(content: Text('公钥地址已复制')));
                    }
                  },
                  child: Row(children: <Widget>[
                    Flexible(child: Text(_pubKey, style: TextStyle(color: Colors.black54))),
                    Padding(padding: const EdgeInsets.only(left: 4), child: Icon(Icons.content_copy, size: 16, color: Colors.black45))
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
                version: 6,
                size: 280,
              ),
            )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Text(
                _pubKeyAutoRefreshTip,
                style: TextStyle(color: Colors.black54),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: InkWell(
                  onTap: () => showRefreshDialog(context),
                  child: Text(
                    '手动刷新',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              )
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Center(
              child: FlatButton(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 56),
                color: Colors.black87,
                highlightColor: Colors.black,
                splashColor: Colors.white10,
                onPressed: share,
                child: Text('分享'),
                textColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
              ),
            ),
          )
        ]));
  }

  void showRefreshDialog(context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('提示'),
            content: Text('刷新公钥地址后，之前的接收的位置密文将永久解密不了！确定继续刷新吗？'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('取消')),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    genNewKeys();
                  },
                  child: Text('确定'))
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
      return TitanPlugin.getExpiredTimeShowTip();
    }).then((tip) {
      _pubKeyAutoRefreshTip = tip;
      setState(() {});
    });
  }

  void share() async {
    try {
      RenderRepaintBoundary boundary = _qrImageBoundaryKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final path = 'qrcode.jpg';
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/$path').create();
      await file.writeAsBytes(pngBytes);

      TitanPlugin.shareImage(path, '分享公钥二维码');
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: '分享发生错误');
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
