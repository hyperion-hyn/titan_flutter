import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/business/infomation/info_detail_page.dart';

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Image.network(
                      infoItemVo.photoUrl,
                      height: 78,
                      width: 110,
                      fit: BoxFit.cover,
                    ),
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
                      style: TextStyle(fontSize: 16, color: Color(0xFF252525)),
                    ),
                    Spacer(),
                    Text(
                      DATE_FORMAT.format(DateTime.fromMillisecondsSinceEpoch(infoItemVo.publishTime)),
                      style: TextStyle(fontSize: 14, color: Color(0xFF9B9B9B)),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTag(String text, int value, int selectedTag, Function onTap) {
    Color textColor = value == selectedTag ? Theme.of(context).primaryColor : Color(0xFF252525);
    Color borderColor = value == selectedTag ? Theme.of(context).primaryColor : Color(0xFFB7B7B7);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: textColor),
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
