import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/widget/smart_drawer.dart';

class MapStoreDrawerScenes extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MapStoreDrawerScenesState();
  }
}

class _MapStoreDrawerScenesState extends State<MapStoreDrawerScenes> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SmartDrawer(
      widthPercent: 0.72,
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            color: Colors.grey[300],
            child: Text("您购买的地图"),
          ),
          Expanded(child: _buildPurcharsedList()),
          _buildPurchseMoreToolbar()
        ],
      ),
    );
  }

  Widget _buildPurchseMoreToolbar() {
    return Material(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            Container(
                height: 35,
                width: 35,
                child: SvgPicture.asset("res/drawable/shop_car.svg", color: Colors.grey[700], semanticsLabel: '')),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "购买更多地图",
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            )
          ],
        ),
      ),
    );
  }

  /**
   * 构建未购买任何地图的view
   */
  Widget _buildEmptyWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            height: 120,
            width: 120,
            child: SvgPicture.asset("res/drawable/empty_box.svg", color: Colors.grey[700], semanticsLabel: '')),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "你尚未购买任何地图",
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "点击前往购买",
            style: TextStyle(color: Colors.blueAccent, fontSize: 14),
          ),
        )
      ],
    );
  }

  /**
   * 构建已购买的地图ListView
   */
  Widget _buildPurcharsedList() {
    return ListView(
      padding: EdgeInsets.all(0),
      children: <Widget>[_buildPurchasedMapItem(true), _buildPurchasedMapItem(false)],
    );
  }

  /**
   * 构建单个已购买地图ListViewItem
   */
  Widget _buildPurchasedMapItem(bool isSelected) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
            border: new Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: 3), // 边色与边宽度
            color: Colors.white, // 底色
            borderRadius: new BorderRadius.circular(8)),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: <Widget>[
                  Image.network(
                    "https://mapstore.oss-cn-hongkong.aliyuncs.com/nightlife.jpeg",
                    width: 60,
                    height: 60,
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                            height: 15, width: 15, child: CircleAvatar(backgroundColor: HexColor("#EE7AE9")))),
                  )
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("全球夜生活旅游地图"),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "这是一个很厉害的故事，这是一个很厉害的故事，这是一个很厉害的故事，这是一个很厉害的故事，",
                        softWrap: true,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              child: Container(
                child: Icon(
                  Icons.check_circle,
                  color: isSelected ? Colors.blue : Colors.transparent,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
