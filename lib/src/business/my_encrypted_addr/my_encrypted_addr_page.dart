import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

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
          title: Text(
            S.of(context).key_manager_title,
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: ListView(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Center(child: Text(S.of(context).main_my_public_key, style: TextStyle(fontSize: 20))),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    if (_pubKey.isNotEmpty) {
                      Clipboard.setData(ClipboardData(text: _pubKey));
                      Scaffold.of(context).showSnackBar(SnackBar(content: Text(S.of(context).public_key_copied)));
                    }
                  },
                  child: Row(children: <Widget>[
                    Flexible(child: Text(_pubKey, style: TextStyle(color: Colors.black54))),
                    Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(Icons.content_copy, size: 16, color: Colors.black45))
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
                size: 240,
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
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Center(
              child: FlatButton(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 56),
                color: Theme.of(context).primaryColor,
                highlightColor: Colors.black,
                splashColor: Colors.white10,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
                onPressed: share,
                child: Text(S.of(context).share),
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
      RenderRepaintBoundary boundary = _qrImageBoundaryKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      // todo: jison edit_esys_flutter_share
      await Share.file(S.of(context).key_manager_title, 'qrcode.jpg', byteData.buffer.asUint8List(), 'image/jpeg');
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: S.of(context).share_fail);
    }
  }

  /*
  static Future<void> file(
      String title, String name, List<int> bytes, String mimeType, {String text = ''}) async {
    Map argsMap = <String, String>{
      'title': '$title',
      'name': '$name',
      'mimeType': '$mimeType',
      'text': '$text'
    };

    final tempDir = await getTemporaryDirectory();
    final file = await new File('${tempDir.path}/$name').create();
    await file.writeAsBytes(bytes);

    _channel.invokeMethod('file', argsMap);
  }
  */

//  void share() async {
//    try {
//      RenderRepaintBoundary boundary = _qrImageBoundaryKey.currentContext.findRenderObject();
//      var image = await boundary.toImage();
//      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
//      Uint8List pngBytes = byteData.buffer.asUint8List();
//
//      final path = 'qrcode.jpg';
//      final tempDir = await getTemporaryDirectory();
//      final file = await new File('${tempDir.path}/$path').create();
//      await file.writeAsBytes(pngBytes);
//      print(file);
//
//      TitanPlugin.shareImage(path, S.of(context).share_qrcode);
//    } catch (e) {
//      print(e.toString());
//      Fluttertoast.showToast(msg: S.of(context).share_fail);
//    }
//  }

}
