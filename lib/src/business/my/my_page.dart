import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/about/about_me_page.dart';
import 'package:titan/src/business/my_encrypted_addr/my_encrypted_addr_page.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';
import 'package:titan/src/utils/utils.dart';

class MyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyPageState();
  }
}

class _MyPageState extends State<MyPage> {
  String _pubKey = "";

  @override
  Future initState() {
    loadData();
    super.initState();
  }

  Future loadData() async {
    _pubKey = await TitanPlugin.getPublicKey();
    setState(() {});
  }

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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    _buildMemuBar("分享app", Icons.share, () {
                      shareApp();
                    }),
                    Divider(),
                    _buildMemuBar("关于我们", Icons.info, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AboutMePage()));
                    }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16, left: 16),
                child: Row(
                  children: <Widget>[
                    Text(
                      "DApp设置",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _buildDappItem(Icons.location_on, "私密分享", "接收地址:${shortEthAddress(_pubKey)}", () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyEncryptedAddrPage()));
                    }),
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
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                iconData,
                color: Color(0xffb4b4b4),
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
    return InkWell(
      onTap: ontap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(padding: const EdgeInsets.all(8.0), child: Icon(iconData, color: Color(0xffb4b4b4), size: 32)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
              ),
              SizedBox(
                height: 4,
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
