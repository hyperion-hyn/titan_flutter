import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';

class DiscoverPageWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DiscoverPageState();
  }
}

class DiscoverPageState extends State<DiscoverPageWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 220,
              child: Carousel(
                images: [
                  NetworkImage("https://www.hyn.space/img/header.jpeg"),
                  NetworkImage("https://www.hyn.space/img/header.jpeg"),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 90),
                  decoration: BoxDecoration(border: Border.all(width: 1)),
                  child: Text("地图应用接入文档"),
                )
              ],
            ),
            Divider(),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    child: Text(
                      "地图DApp",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildDappItem(ExtendsIconFont.point, "私密分享", "分享加密位置，绝不泄露位置信息"),
                  Divider(),
                  _buildDappItem(ExtendsIconFont.female, "夜生活指南", "夜蒲不再迷路"),
                  Divider(),
                  _buildDappItem(ExtendsIconFont.police_car, "警察服务站", "有困难找警察"),
                  Divider(),
                  _buildDappItem(ExtendsIconFont.embassy, "全球大使馆", "我家大使馆就在这"),
                  Divider(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDappItem(IconData iconData, String title, String description) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(top: 8, bottom: 8, right: 16),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 1),
              color: Colors.white,
            ),
            child: Center(child: Icon(iconData, color: Colors.black, size: 24))),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(description),
          ],
        )
      ],
    );
  }
}
