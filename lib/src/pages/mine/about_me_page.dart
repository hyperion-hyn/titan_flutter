import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:titan/env.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/updater/bloc/bloc.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AboutMeState();
  }
}

class _AboutMeState extends BaseState<AboutMePage> {
  String version = "";

  @override
  void onCreated() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        version = packageInfo.version;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var languageCode = Localizations.localeOf(context).languageCode;

    Widget _lineWidget({double height = 5}) {
      return Container(
        height: height,
        color: HexColor('#F8F8F8'),
      );
    }

    Widget _dividerWidget() {
      return Padding(
        padding: const EdgeInsets.only(
          left: 16,
        ),
        child: Container(
          height: 0.8,
          color: HexColor('#F8F8F8'),
        ),
      );
    }

    return Scaffold(
        appBar: BaseAppBar(
          baseTitle: S.of(context).about_us,
          backgroundColor: Colors.white,
        ),
        body: ListView(children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
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

          _buildInfoContainer(
              label: S.of(context).official_website,
              showValue: "https://www.hyn.space/",
              value: "https://www.hyn.space/",
              isUrl: true),
          _buildInfoContainer(
              label: '区块链浏览器', showValue: "https://hynscan.io/", value: "https://hynscan.io/", isUrl: true),
          _buildInfoContainer(
              label: '开源地址',
              showValue: "https://github.com/hyperion-hyn/",
              value: "https://github.com/hyperion-hyn/",
              isUrl: true),
          _buildInfoContainer(label: '开源协议 MIT', showValue: Const.APP_POLICY, value: Const.APP_POLICY, isUrl: true),
          _buildInfoContainer(
              label: S.of(context).forum,
              showValue: "https://talk.hyn.space/",
              value: "https://talk.hyn.space/",
              isUrl: true),
          _lineWidget(),
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
            showValue: "@hyperionsgofficial",
            value: "@hyperionsgofficial",
          ),
          _buildInfoContainer(label: S.of(context).wechat, showValue: "@HyperionHYN", value: "HyperionHYN"),
          _buildInfoContainer(label: S.of(context).wechat_official_account, showValue: "@kaizshuo", value: "kaizshuo"),
          if (languageCode == "en")
            _buildInfoContainer(
                label: S.of(context).telegram_operator, showValue: "@FriedrichLVZX", value: "FriedrichLVZX"),
          // if (languageCode == "zh")
          //   _buildInfoContainer(
          //     label: S.of(context).wechat_cs,
          //     showValue: "@Bi321369",
          //     value: "@Bi321369",
          //   ),

          _lineWidget(),
        ]));
  }

  Widget _buildInfoContainer({String label, String showValue, String value, bool isUrl: false}) {
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
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: DefaultColors.color333,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    isUrl
                        ? Text(
                            showValue,
                            style: TextStyle(
                              color: Colors.grey ,
                              fontSize: 12,
                            ),
                          )
                        : Row(
                            children: [
                              Text(
                                showValue,
                                style: TextStyle(
                                  color: Colors.grey ,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Icon(
                                Icons.copy,
                                color: Colors.grey,
                                size: 12,
                              )
                            ],
                          ),
                  ],
                ),
              ),
              if (isUrl)
                Padding(
                  padding: const EdgeInsets.only(left: 60,),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
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
