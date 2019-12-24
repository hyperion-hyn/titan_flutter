import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/my/about_me_page.dart';
import 'package:titan/src/business/my/me_setting_page.dart';
import 'package:titan/src/business/my/my_encrypted_addr_page.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
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
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {
    _pubKey = await TitanPlugin.getPublicKey();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              height: 200.0 + MediaQuery.of(context).padding.top,
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [/*Color(0xff041528),*/ Theme.of(context).primaryColor, Color(0xff99C3E6)],
                        begin: FractionalOffset(0, 0.4),
                        end: FractionalOffset(0, 1))),
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
                        Text(S.of(context).titan_encrypted_map_ecology, style: TextStyle(color: Colors.white70))
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
//              padding: EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  _buildMenuBar(S.of(context).share_app, Icons.share, () => shareApp()),
                  Padding(
                    padding: const EdgeInsets.only(left: 56.0),
                    child: Divider(height: 0),
                  ),
                  _buildMenuBar(S.of(context).about_us, Icons.info,
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => AboutMePage()))),
                  Padding(
                    padding: const EdgeInsets.only(left: 56.0),
                    child: Divider(height: 0),
                  ),
                  _buildMenuBar(S.of(context).setting, Icons.settings,
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => MeSettingPage()))),
                  Divider(
                    height: 0,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16, left: 16),
              child: Row(
                children: <Widget>[
                  Text(
                    S.of(context).dapp_setting,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Divider(height: 0),
                _buildDMapItem(Icons.location_on, S.of(context).private_share,
                    S.of(context).private_share_receive_address(shortEthAddress(_pubKey)), () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyEncryptedAddrPage()));
                }),
                Divider(height: 0),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMenuBar(String title, IconData iconData, Function onTap) {
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Ink(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: <Widget>[
              Icon(
                iconData,
                color: Color(0xffb4b4b4),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
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
      ),
    );
  }

  Widget _buildDMapItem(IconData iconData, String title, String description, Function ontap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: ontap,
        child: Ink(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(iconData, color: Color(0xffb4b4b4), size: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
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
        ),
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
