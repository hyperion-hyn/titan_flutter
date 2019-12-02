import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/global.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:titan/generated/i18n.dart';
import 'widget_shot.dart';
import 'dart:typed_data';

class PromoteQrCodePage extends StatelessWidget {
  final String url;
  final ShotController _shotController = new ShotController();

  PromoteQrCodePage(this.url);

  @override
  Widget build(BuildContext context) {
    print('[QR] ---> build');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "邀请二维码",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              color: Colors.white,
              tooltip: '分享',
              onPressed: (){
                _shareQr(context);
              },
            ),
        ],
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: WidgetShot(
        controller: _shotController,
        child: _newBody(),
      ),
    );
  }


  Widget _oldBody() {
    return Center(
      child: Container(
        padding: EdgeInsets.fromLTRB(40, 40, 40, 40),
        child: QrImage(
          data: url,
          backgroundColor: Colors.white,
          version: 4,
          size: 240,
        ),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      ),
    );
  }


  Widget _newBody() {
    return Stack(
      children: <Widget>[
        Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("res/drawable/invitation_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 22,
          height: 96,
          child: Container(
            color: HexColor('#343434').withOpacity(1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 18, bottom: 18, left: 30, right: 8),
                  child: QrImage(
                    data: url,
                    padding: EdgeInsets.all(.0),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    version: 3,
                    size: 60,
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      LOGIN_USER_INFO.id,
                      style: TextStyle(color: HexColor('#FEFEFE'), fontSize: 16),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      '邀请你加入星际掘金',
                      style: TextStyle(color: HexColor('#FEFEFE'), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _shareQr(BuildContext context) async {

//    print('_shareQr --> action, _shotController: ${_shotController.hashCode}');
//    print('_shareQr --> action, globalKey:${_shotController.globalKey.currentContext}, context:${context}');

    Uint8List imageByte = await _shotController.makeImageUint8List();
    await Share.file(S.of(context).nav_share_app, 'app.png', imageByte, 'image/png');
  }

}

