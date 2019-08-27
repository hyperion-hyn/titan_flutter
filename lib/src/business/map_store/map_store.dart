import 'package:flutter/material.dart';

class MapStorePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MapStorePageState();
  }
}

class _MapStorePageState extends State<MapStorePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("地图商店"),
      ),
      body: ListView(
        padding: EdgeInsets.all(0),
        children: <Widget>[_buildMapStoreItem()],
      ),
    );
  }

  Widget _buildMapStoreItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18,vertical: 8.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Image.network(
                  "https://mapstore.oss-cn-hongkong.aliyuncs.com/nightlife.jpeg",
                  width: 70,
                  height: 70,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "会所地图",
                      style: TextStyle(fontSize: 15),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "HYN",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    )
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black87, width: 3), // 边色与边宽度
                        color: Colors.black87, // 底色
                        borderRadius: BorderRadius.circular(6)),
                    height: 40,
                    child: MaterialButton(
                      elevation: 0,
                      highlightElevation: 0,
                      minWidth: 60,
                      onPressed: () {},
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      textColor: Color(0xddffffff),
                      highlightColor: Colors.black,
                      splashColor: Colors.white10,
                      child: Row(
                        children: <Widget>[
                          Text(
                            "购买",
                            style: TextStyle(fontSize: 14, color: Color(0xddffffff)),
                          )
                        ],
                      ),
                    ),
                  ),
                  Text("HKD 6.00/月")
                ],
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Stack(
              children: <Widget>[
                Text(
                  "展示全球主要城市警察局地图及位置详情，安全出行好帮手",
                  softWrap: true,
                  style: TextStyle(color: Colors.grey[600], fontSize: 17),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Text(
                        "更多",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Text(
            "该地图层展示位于伦敦、香港、雅加达、三藩市和洛杉矶的警察局位置详情，保障用户出行安全，为需要的用户提供及时方便的的信息查询、导航和分享功能。展示信息包含警察局名称、地址及联系电话等。凡有需要的用户即可一键获取警察局位置详情寻求帮助。\n\n该地图显示语言以中英文为主。一些地标性建筑将以当地语言显示。\n\n*Titan Map Store上下载的地图层只适用于Titan地图。",
            softWrap: true,
            style: TextStyle(color: Colors.grey[600], fontSize: 17),
          )
        ],
      ),
    );
  }
}
