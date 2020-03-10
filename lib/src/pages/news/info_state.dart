import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

import './info_detail_page.dart';

typedef OnActiveTag = void Function(int tagId);

abstract class InfoState<T extends StatefulWidget> extends State<T> {
  DateFormat DATE_FORMAT = new DateFormat("yy/MM/dd HH:mm");

  Widget buildInfoItem(InfoItemVo infoItemVo) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => InfoDetailPage(
                      id: infoItemVo.id,
                      url: infoItemVo.url,
                      title: infoItemVo.title,
                    )));
      },
      child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
//                  alignment: Alignment.center,
                    child: FadeInImage.assetNetwork(
                      image: infoItemVo.photoUrl,
                      placeholder: 'res/drawable/img_placeholder.jpg',
                      width: 112,
                      height: 84,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        infoItemVo.title,
                        style: TextStyle(fontSize: 16, color: Color(0xFF252525))),
                      Spacer(),
                      Text(
                        DATE_FORMAT.format(DateTime.fromMillisecondsSinceEpoch(infoItemVo.publishTime)),
                        style: TextStyle(fontSize: 14, color: Color(0xFF9B9B9B)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTag(String text, int value, bool isActive, OnActiveTag onActiveTag, {bool isUpdate = false}) {
    Color textColor = isActive ? Theme.of(context).primaryColor : Color(0xFF252525);
    Color borderColor = isActive ? Theme.of(context).primaryColor : Color(0xFFB7B7B7);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () {
          if (onActiveTag != null) {
            onActiveTag(value);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: !isUpdate
              ? Text(
                  text,
                  style: TextStyle(fontSize: 13, color: textColor),
                )
              : Row(
                  children: <Widget>[
                    Text(
                      text,
                      style: TextStyle(fontSize: 13, color: textColor),
                    ),
                    Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Container(
                              height: 6,
                              width: 6,
                              decoration: BoxDecoration(
                                  color: HexColor("#DA3B2A"),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: HexColor("#DA3B2A"))),
                            ),
                          ),
                  ],
                ),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), border: Border.all(color: borderColor)),
        ),
      ),
    );
  }
}

class InfoItemVo {
  int id;
  String photoUrl;
  String title;
  String publisher;
  String url;
  int publishTime;

  InfoItemVo({this.id, this.photoUrl, this.title, this.publisher, this.url, this.publishTime});
}
