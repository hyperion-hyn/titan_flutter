import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/my_encrypted_addr/my_encrypted_addr_page.dart';
import 'package:titan/src/business/webview/webview.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/smart_drawer.dart';

class DrawerScenes extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DrawerScenesState();
  }
}

class _DrawerScenesState extends State<DrawerScenes> {
  String _pubKey = "";
  String _pubKeyAutoRefreshTip = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    var expireTime = await TitanPlugin.getExpiredTime();
    var timeLeft = (expireTime - DateTime.now().millisecondsSinceEpoch) ~/ 1000;
    if (timeLeft <= 0) {
      _pubKeyAutoRefreshTip = getExpiredTimeShowTip(expireTime);
      _pubKey = '';
      setState(() {});

      TitanPlugin.genKeyPair().then((pub) async {
        _pubKey = pub;
        expireTime = await TitanPlugin.getExpiredTime();
        _pubKeyAutoRefreshTip = getExpiredTimeShowTip(expireTime);
        setState(() {});
      });
    } else {
      _pubKey = await TitanPlugin.getPublicKey();
      _pubKeyAutoRefreshTip = getExpiredTimeShowTip(expireTime);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SmartDrawer(
      widthPercent: 0.72,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xff212121), Color(0xff000000)],
                    begin: FractionalOffset(0, 0.4),
                    end: FractionalOffset(0, 1))),
            height: 200.0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Image.asset('res/drawable/ic_logo.png', width: 40.0),
                        SizedBox(width: 8),
                        Image.asset('res/drawable/logo_title.png', width: 72.0)
                      ],
                    ),
                    SizedBox(height: 16),
                    Text('我的隐私地图', style: TextStyle(color: Colors.white70))
                  ],
                ),
              ),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyEncryptedAddrPage()));
            },
            leading: Icon(Icons.lock),
            title: Text('我的加密地址(公钥)'),
            trailing: Icon(Icons.navigate_next),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.all(8),
            color: Colors.grey[200],
            child: GestureDetector(
              onTap: () {
                if (_pubKey.isNotEmpty) {
                  Clipboard.setData(ClipboardData(text: _pubKey));
                  Fluttertoast.showToast(msg: '公钥地址已复制');
                }
              },
              child: Row(
                children: <Widget>[
                  Flexible(
                      child: Text(
                    _pubKey,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  )),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.content_copy,
                      size: 16,
                      color: Colors.black45,
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(_pubKeyAutoRefreshTip, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          Container(height: 8, color: Colors.grey[100]),
          ListTile(
            onTap: () {
              print('test cancel');
            },
            leading: Icon(Icons.map),
            title: Text(S.of(context).offline_map),
            trailing: Icon(Icons.navigate_next),
          ),
          Container(height: 8, color: Colors.grey[100]),
          ListTile(
            onTap: shareApp,
            leading: Icon(Icons.share),
            title: Text('分享App'),
            trailing: Icon(Icons.navigate_next),
          ),
          Container(height: 1, color: Colors.grey[100]),
          ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                return WebViewPage();
              }));
            },
            leading: Icon(Icons.info),
            title: Text('关于我们'),
            trailing: Icon(Icons.navigate_next),
          )
        ],
      ),
    );
  }

  void shareApp() async {
    final path = 'share_app.jpg';
    final tempDir = await getTemporaryDirectory();
    File file = File('${tempDir.path}/$path');
    var exist = await file.exists();
    if (!exist) {
      var sharePic = 'res/drawable/share_app_zh_android.jpeg';
      if (ui.window.locale.languageCode != 'zh') {
        sharePic = 'res/drawable/share_app_en_android.jpeg';
      }
      file = await file.create();
      final ByteData bytes = await rootBundle.load(sharePic);
      final Uint8List list = bytes.buffer.asUint8List();
      file.writeAsBytesSync(list);
    }

    TitanPlugin.shareImage(path, '分享Titan');
  }
}
