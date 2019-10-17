import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/about/about_me_page.dart';
import 'package:titan/src/business/my_encrypted_addr/my_encrypted_addr_page.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';

class MyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyPageState();
  }
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                height: 200.0,
                child: Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Color(0xff212121), Theme.of(context).primaryColor],
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
                              Text("Titan 加密地图生态", style: TextStyle(color: Colors.white70))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildMemuBar("分享app", Icons.share, () {
                shareApp();
              }),
              _buildMemuBar("关于我们", Icons.info, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AboutMePage()));
              }),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: Text(
                        "DApp设置",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildDappItem(ExtendsIconFont.point, "私密分享", "接受地址:0x543254543542545342542545435", () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyEncryptedAddrPage()));
                    }),
                    Divider(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemuBar(String title, IconData iconData, Function onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration:
            BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black12), shape: BoxShape.rectangle),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                iconData,
                color: Colors.black54,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),
            Spacer(),
            Icon(
              Icons.chevron_right,
              color: Colors.black54,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDappItem(IconData iconData, String title, String description, Function ontap) {
    return GestureDetector(
      onTap: ontap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(top: 8, bottom: 8, right: 16),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 1),
                color: Colors.white,
              ),
              child: Center(child: Icon(iconData, color: Colors.black, size: 24))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          Spacer(),
          Icon(
            Icons.chevron_right,
            color: Colors.black54,
          )
        ],
      ),
    );
  }

  void shareApp() async {
    var languageCode = Localizations.localeOf(context).languageCode;
    var shareAppImage = "";

    if (languageCode == "zh") {
      shareAppImage = "res/drawable/share_app_zh_android.jpeg";
    } else {
      shareAppImage = "res/drawable/share_app_en_android.jpeg";
    }

    final ByteData imageByte = await rootBundle.load(shareAppImage);
    await Share.file(S.of(context).nav_share_app, 'app.png', imageByte.buffer.asUint8List(), 'image/jpeg');
  }
}
