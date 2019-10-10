import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AboueMeState();
  }
}

class _AboueMeState extends State<AboutMePage> {
  String version = "";

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      version = packageInfo.version;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var languageCode = Localizations.localeOf(context).languageCode;
    return Scaffold(
        appBar: AppBar(title: Text(S.of(context).about_us)),
        body: ListView(children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'res/drawable/ic_logo.png',
                  color: Colors.black,
                  width: 50,
                  height: 50,
                ),
                Image.asset(
                  'res/drawable/logo_title.png',
                  color: Colors.black,
                  width: 100,
                )
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    S.of(context).app_version,
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                  Spacer(),
                  Text(
                    version,
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          _buildInfoContainer(
              label: S.of(context).official_website,
              showValue: "https://www.hyn.space/",
              value: "https://www.hyn.space/",
              isUrl: true),
          _buildInfoContainer(
              label: S.of(context).forum,
              showValue: "https://talk.hyn.space/",
              value: "https://talk.hyn.space/",
              isUrl: true),
          _buildInfoContainer(
              label: S.of(context).telegram, showValue: "@hypersionOfficianHYN", value: "hypersionOfficianHYN"),
          _buildInfoContainer(label: S.of(context).twitterhyperion, showValue: "@TitanHYN", value: "TitanHYN"),
          _buildInfoContainer(
            label: S.of(context).twittertitan,
            showValue: "@HyperionHYN",
            value: "HyperionHYN",
          ),
          _buildInfoContainer(
            label: S.of(context).medium,
            showValue: "@hyperionsgoffical",
            value: "@hyperionsgoffical",
          ),
          _buildInfoContainer(label: S.of(context).wechat, showValue: "@HyperionHYN", value: "HyperionHYN"),
          _buildInfoContainer(label: S.of(context).wechat_official_account, showValue: "@kaizshuo", value: "kaizshuo"),
          if (languageCode == "en")
            _buildInfoContainer(
                label: S.of(context).telegram_operator, showValue: "@FriedrichLVZX", value: "FriedrichLVZX"),
          if (languageCode == "zh")
            _buildInfoContainer(
              label: S.of(context).wechat_cs,
              showValue: "@Bi321369",
              value: "@Bi321369",
            ),
        ]));
  }

  Widget _buildInfoContainer({String label, String showValue, String value, bool isUrl: false}) {
    Color showValueTextColor = isUrl ? Colors.grey : Colors.blue;
    return GestureDetector(
      onTap: () {
        if (isUrl) {
          _openUrl(value, label);
        } else {
          _copyText(value);
        }
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 1, 0, 0),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
              Spacer(),
              Text(
                showValue,
                style: TextStyle(color: showValueTextColor),
              ),
              if (isUrl)
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                )
            ],
          ),
        ),
      ),
    );
  }

  Future _openUrl(String url, String title) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  void _copyText(String text) {
    Clipboard.setData(new ClipboardData(text: text));
    Fluttertoast.showToast(msg: S.of(context).copyed);
  }
}
