import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:titan/src/pages/news/model/news_detail.dart';

class AnnouncementDialog extends StatelessWidget {
  final Function onCancel;
  final NewsDetail announcement;

  AnnouncementDialog(this.announcement, this.onCancel);

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
              child: Html(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                data: announcement.content,
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

/*@override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: FractionalOffset(0.5, 0.6),
          child: Stack(
            children: <Widget>[
              Container(
                height: 510,
                width: 300,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(3.0),
                    child: Image.asset(
                      "res/drawable/bg_app_nnouncement.jpeg",
                      fit: BoxFit.cover,
                    )),
              ),
              Positioned(
                  right: 15,
                  top: 15,
                  child: InkWell(
                    onTap: () {
                      onCancel();
                    },
                    child: Image.asset(
                      "res/drawable/wifi_close.png",
                      fit: BoxFit.fill,
                      width: 20,
                      height: 20,
                    ),
                  )),
            ],
          ),
        ),
        Align(
          alignment: FractionalOffset(0.5, 0.6),
          child: Container(
              height: 510,
              width: 300,
              padding: EdgeInsets.only(top: 40, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    announcement.title,
                    style: TextStyles.textCf5bS19,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: Container(
                      width: 280,
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 15, bottom: 15),
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),//设置四周圆角 角度
                      ),
                      child: Text(
                        "新增宅经济新增宅经济新增宅经济新增宅经济新增宅经济新增宅经济新增宅经济新增宅经济新增宅经济新增宅经济",
                        style: TextStyles.textC333S14,
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ],
    );
  }*/

}
