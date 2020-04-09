import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:titan/src/pages/news/model/news_detail.dart';

class AnnouncementDialog extends StatelessWidget {
  final Function onCancel;
  final NewsDetail announcement;

  AnnouncementDialog(this.announcement, this.onCancel);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 48),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.88,
          heightFactor: 0.88,
          child: Center(
            child: Stack(
              children: <Widget>[
                ClipRRect(
//            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.red)),
//            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//            height: 540,
//            width: 370,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  child: SingleChildScrollView(
                    child: Html(
                      data: announcement.content,
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: InkWell(
                    onTap: () {
                      onCancel();
                    },
                    child: Icon(
                      Icons.cancel,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
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
