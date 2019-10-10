import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/business/infomation/info_detail_page.dart';

class InformationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _InformationPageState();
  }
}

class _InformationPageState extends State<InformationPage> {
  int _selectedTabIndex = 0;

  DateFormat DATE_FORMAT = new DateFormat("yy/MM/dd HH:mm");

  List<InfoItemVo> _list = [
    InfoItemVo(
        url: "https://mp.weixin.qq.com/s/-To2YbOhckbEizF80xUk9w",
        photoUrl: "http://imgtravel.gmw.cn/attachement/jpg/site2/20190919/f44d30758ab01eed1e0719.jpg",
        title: '捷星周五特惠|精明的旅行者已经开始"早鸟计划"啦',
        publisher: "捷星航空",
        publishTime: 1570183149000),
    InfoItemVo(
        url: "https://mp.weixin.qq.com/s/-To2YbOhckbEizF80xUk9w",
        photoUrl: "http://imgtravel.gmw.cn/attachement/jpg/site2/20190919/f44d30758ab01eed1e0719.jpg",
        title: '捷星周五特惠|精明的旅行者已经开始"早鸟计划"啦',
        publisher: "捷星航空",
        publishTime: 1570183149000),
    InfoItemVo(
        url: "https://mp.weixin.qq.com/s/-To2YbOhckbEizF80xUk9w",
        photoUrl: "http://imgtravel.gmw.cn/attachement/jpg/site2/20190919/f44d30758ab01eed1e0719.jpg",
        title: '捷星周五特惠|精明的旅行者已经开始"早鸟计划"啦',
        publisher: "捷星航空",
        publishTime: 1570183149000),
    InfoItemVo(
        url: "https://mp.weixin.qq.com/s/-To2YbOhckbEizF80xUk9w",
        photoUrl: "http://imgtravel.gmw.cn/attachement/jpg/site2/20190919/f44d30758ab01eed1e0719.jpg",
        title: '捷星周五特惠|精明的旅行者已经开始"早鸟计划"啦,捷星周五特惠|精明的旅行者已经开始"早鸟计划"啦,捷星周五特惠|精明的旅行者已经开始"早鸟计划"啦',
        publisher: "捷星航空",
        publishTime: 1570183149000),
    InfoItemVo(
        url: "https://mp.weixin.qq.com/s/-To2YbOhckbEizF80xUk9w",
        photoUrl: "https://inews.gtimg.com/newsapp_match/0/9285688304/0",
        title: '捷星周五特惠|精明的旅行者已经开始"早鸟计划"啦',
        publisher: "捷星航空",
        publishTime: 1570183149000),
    InfoItemVo(
        url: "https://mp.weixin.qq.com/s/-To2YbOhckbEizF80xUk9w",
        photoUrl: "http://imgtravel.gmw.cn/attachement/jpg/site2/20190919/f44d30758ab01eed1e0719.jpg",
        title: '捷星周五特惠|精明的旅行者已经开始"早鸟计划"啦',
        publisher: "捷星航空",
        publishTime: 1570183149000),
    InfoItemVo(
        url: "https://mp.weixin.qq.com/s/-To2YbOhckbEizF80xUk9w",
        photoUrl: "http://imgtravel.gmw.cn/attachement/jpg/site2/20190919/f44d30758ab01eed1e0719.jpg",
        title: '捷星周五特惠|精明的旅行者已经开始"早鸟计划"啦',
        publisher: "捷星航空",
        publishTime: 1570183149000),
    InfoItemVo(
        url: "https://mp.weixin.qq.com/s/-To2YbOhckbEizF80xUk9w",
        photoUrl: "http://imgtravel.gmw.cn/attachement/jpg/site2/20190919/f44d30758ab01eed1e0719.jpg",
        title: '捷星周五特惠|精明的旅行者已经开始"早鸟计划"啦',
        publisher: "捷星航空",
        publishTime: 1570183149000),
    InfoItemVo(
        url: "https://mp.weixin.qq.com/s/-To2YbOhckbEizF80xUk9w",
        photoUrl: "http://imgtravel.gmw.cn/attachement/jpg/site2/20190919/f44d30758ab01eed1e0719.jpg",
        title: '捷星周五特惠|精明的旅行者已经开始"早鸟计划"啦',
        publisher: "捷星航空",
        publishTime: 1570183149000),
    InfoItemVo(
        url: "https://mp.weixin.qq.com/s/-To2YbOhckbEizF80xUk9w",
        photoUrl: "http://imgtravel.gmw.cn/attachement/jpg/site2/20190919/f44d30758ab01eed1e0719.jpg",
        title: '捷星周五特惠|精明的旅行者已经开始"早鸟计划"啦',
        publisher: "捷星航空",
        publishTime: 1570183149000),
    InfoItemVo(
        url: "https://mp.weixin.qq.com/s/-To2YbOhckbEizF80xUk9w",
        photoUrl: "http://imgtravel.gmw.cn/attachement/jpg/site2/20190919/f44d30758ab01eed1e0719.jpg",
        title: '捷星周五特惠|精明的旅行者已经开始"早鸟计划"啦',
        publisher: "捷星航空",
        publishTime: 1570183149000),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 8, right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CupertinoSegmentedControl<int>(
                children: {
                  0: _buildTabItem("资讯"),
                  1: _buildTabItem("凯式物语"),
                },
                onValueChanged: (value) {
                  _selectedTabIndex = value;
                  setState(() {});
                },
                groupValue: _selectedTabIndex,
              ),
            ),
            Expanded(
              child: ListView.separated(
                  itemBuilder: (context, index) {
                    return _buildInfoItem(_list[index]);
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemCount: _list.length),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 24),
      child: Text(title),
    );
  }

  Widget _buildInfoItem(InfoItemVo infoItemVo) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => InfoDetailPage(
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
              child: Container(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Image.network(infoItemVo.photoUrl),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        infoItemVo.publisher,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Spacer(),
                      Text(
                        DATE_FORMAT.format(DateTime.fromMillisecondsSinceEpoch(infoItemVo.publishTime)),
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    ],
                  ),
                  Text(infoItemVo.title),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class InfoItemVo {
  String photoUrl;
  String title;
  String publisher;
  String url;
  int publishTime;

  InfoItemVo({this.photoUrl, this.title, this.publisher, this.url, this.publishTime});
}
