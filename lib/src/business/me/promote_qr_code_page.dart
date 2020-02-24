import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/global.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'widget_shot.dart';
import 'dart:typed_data';

class PromoteQrCodePage extends StatefulWidget {

  final String url;

  PromoteQrCodePage(this.url);

  @override
  State<StatefulWidget> createState() {
    return _PromoteQrCodePageState();
  }
}

class _PromoteQrCodePageState extends State<PromoteQrCodePage> {

  final ShotController _shotController = new ShotController();
  List<String> imagesList = [];
  var shareAppImage = "";

  @override
  Widget build(BuildContext context) {
    print('[QR] ---> _body, url:$widget.url, id:${LOGIN_USER_INFO.id}');

    if(shareAppImage.isEmpty) {
      var languageCode = Localizations
          .localeOf(context)
          .languageCode;

      if (languageCode == "zh") {
        shareAppImage = "res/drawable/invitation_bg.png";
        imagesList.add("res/drawable/invitation_bg.png");
      } else {
        shareAppImage = "res/drawable/invitation_bg_en.png";
        imagesList.add("res/drawable/invitation_bg_en.png");
      }

      imagesList.add("res/drawable/invitation_bg_2.jpg");
      imagesList.add("res/drawable/invitation_bg_3.jpg");
      imagesList.add("res/drawable/invitation_bg_4.jpg");
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).invitate_qr,
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            color: Colors.white,
            tooltip: S.of(context).share,
            onPressed: () {
              _shareQr(context);
            },
          ),
        ],
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {

    return Stack(
      children: <Widget>[
        WidgetShot(
          controller: _shotController,
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(shareAppImage),
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
                        margin:
                            EdgeInsets.only(top: 18, bottom: 18, left: 30, right: 8),
                        child: QrImage(
                          data: widget.url,
                          padding: EdgeInsets.all(0.0),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          version: 4,
                          size: 60,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            LOGIN_USER_INFO.id,
                            style:
                                TextStyle(color: HexColor('#FEFEFE'), fontSize: 16),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            S.of(context).invite_join + " " + S.of(context).app_name,
                            style:
                                TextStyle(color: HexColor('#FEFEFE'), fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
            left: 0,
            right: 0,
            bottom: 118,
            child: _bottomImageList())
      ],
    );
  }

  void _shareQr(BuildContext context) async {
//    print('_shareQr --> action, _shotController: ${_shotController.hashCode}');
//    print('_shareQr --> action, globalKey:${_shotController.globalKey.currentContext}, context:${context}');

    Uint8List imageByte = await _shotController.makeImageUint8List();
    await Share.file(
        S.of(context).nav_share_app, 'app.png', imageByte, 'image/png');
  }

  Widget _bottomImageList(){
    return Container(
      color: HexColor('#343434').withOpacity(0.5),
      padding: EdgeInsets.only(left: 15.0, bottom: 8, top: 8,right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("更换背景图：",style: TextStyles.textCfffS12),
          SizedBox(height: 10),
          Container(
            height: 40,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          shareAppImage = imagesList[index];
                        });

                      },
                      child: Container(
                        width: 40,
                        /*decoration: BoxDecoration(
                        color: HexColor('#D8D8D8'),
                        borderRadius: BorderRadius.circular(3.0),
                      ),*/
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3.0),
                          child: Image.asset(
                            imagesList[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: imagesList.length),
          ),
        ],
      ),
    );
  }

}
