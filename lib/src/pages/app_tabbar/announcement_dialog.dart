import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/news/model/news_detail.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:url_launcher/url_launcher.dart';

class AnnouncementDialog extends StatelessWidget {
  final Function onCancel;
  final NewsDetail announcement;

  AnnouncementDialog(this.announcement, this.onCancel);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent.withOpacity(0.5),
      child: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 300,
                height: MediaQuery.of(context).size.height * 0.55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      "res/drawable/pronounce_top.png",
                      width: 300,
                      height: 88,
                      fit: BoxFit.fill,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0, bottom: 15),
                      child: Text(
                        this.announcement?.title ?? S.of(context).announcement,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: DefaultColors.color333,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        child: CupertinoScrollbar(
                          child: SingleChildScrollView(
                            //physics: NeverScrollableScrollPhysics(),
                            child: Html(
                              data: announcement.content,
                              onLinkTap: (String url) {
                                _openUrl(url);
                                // onCancel();
                              },
                              onImageTap: (String url) {
                                _openUrl(url);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Image.asset(
                      "res/drawable/pronounce_bottom.png",
                      width: 300,
                      height: 40,
                      fit: BoxFit.fill,
                    ),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(
                  30,
                ),
                onTap: () {
                  onCancel();
                },
                child: Padding(
                  padding: const EdgeInsets.all(17.0),
                  child: Image.asset(
                    "res/drawable/ic_dialog_close.png",
                    width: 30,
                    height: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _openUrl(String originalUrl) async {
    var newUrl = originalUrl;

    // todo : test map3 创建界面
    //newUrl = '/map3node/pre_create_contract_page';

    var context = Keys.rootKey.currentContext;

    // 1.网页
    if (newUrl.startsWith("http") || newUrl.startsWith("https")) {
      var scanStr = FluroConvertUtils.fluroCnParamsEncode(newUrl);
      Application.router.navigateTo(context, Routes.toolspage_webview_page + "?initUrl=$scanStr");
    }
    // 2.应用内协议
    else if (newUrl.startsWith('titan://')) {
      // titan://
      onCancel();
    }
    // 3.应用内路由
    else if (newUrl.startsWith('/')) {
      await Application.router.navigateTo(context, newUrl);
    }
    // 4.其他
    else {
      if (await canLaunch(newUrl)) {
        await launch(newUrl);
      } else {
        print('Could not launch $newUrl');
      }
    }
  }
}

class AnnouncementDialogOld extends StatelessWidget {
  final Function onCancel;
  final NewsDetail announcement;

  AnnouncementDialogOld(this.announcement, this.onCancel);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: FractionalOffset(0.5, 0.6),
          child: Container(
            height: 510,
            width: 370,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Html(
                  data: announcement.content,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: FractionalOffset(0.5, 0.93),
          child: InkWell(
            onTap: () {
              onCancel();
            },
            child: Image.asset(
              "res/drawable/ic_select_category_search_bar_clear.png",
              fit: BoxFit.fill,
              width: 32,
              height: 32,
            ),
          ),
        )
      ],
    );
  }
}
