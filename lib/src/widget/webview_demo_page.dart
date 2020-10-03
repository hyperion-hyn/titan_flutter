import 'package:flutter/material.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class WebviewDemoPage extends StatefulWidget {
  WebviewDemoPage();

  @override
  State<StatefulWidget> createState() {
    return _WebviewDemoPageState();
  }
}

class _WebviewDemoPageState extends State<WebviewDemoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: BaseAppBar(baseTitle: "WebviewDemoPage"),
        body: Column(
          children: <Widget>[
            ClickOvalButton("帮助页面",(){
              String webUrl = FluroConvertUtils.fluroCnParamsEncode("http://ec2-46-137-195-189.ap-southeast-1.compute.amazonaws.com/helpPage");
              String webTitle = FluroConvertUtils.fluroCnParamsEncode("帮助页面");
              Application.router
                  .navigateTo(context, Routes.toolspage_webview_page + '?initUrl=$webUrl&title=$webTitle');
            })
          ],
        ));
  }
}