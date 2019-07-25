import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/business/home/poi_bottom_sheet.dart';

import 'package:titan/src/business/search/search_page.dart';
import 'package:titan/src/model/search_poi.dart';
import 'package:titan/src/widget/draggable_bottom_sheet.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

import 'map_scenes.dart';
import 'bottom_fabs_scenes.dart';
import 'drawer_scenes.dart';
import 'searching_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _lastPressedAt;
  DraggableBottomSheetController _draggableBottomSheetController = DraggableBottomSheetController(collapsedHeight: 100);
  ScrollController _bottomSheetScrollController = ScrollController();

  final TextEditingController _searchTextController = TextEditingController();

  bool _isSearching = false;
  bool _isShowingSearch = false;

  SearchPoiEntity _selectedPoiEntity;

  void _showPoi(SearchPoiEntity poi) {
    setState(() {
      _selectedPoiEntity = poi;
      _draggableBottomSheetController.setSheetState(DraggableBottomSheetState.COLLAPSED);
    });
//    Future.delayed(Duration(milliseconds: 200)).then((data) {
//      _draggableBottomSheetController.setSheetState(DraggableBottomSheetState.COLLAPSED);
//    });
  }

  void _searchText(text) {
    _searchTextController.text = text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        drawer: DrawerScenes(),
        body: WillPopScope(
          onWillPop: () async {
            if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt) > Duration(seconds: 2)) {
              _lastPressedAt = DateTime.now();
              Fluttertoast.showToast(msg: '再按一下退出程序');
              return false;
            }
            return true;
          },
          child: Builder(
              builder: (BuildContext ctx) => Stack(
                    children: <Widget>[
                      ///地图渲染
                      MapScenes(_draggableBottomSheetController),

                      ///搜索入口
                      buildSearchWidget(ctx),

                      ///主要是支持drawer手势划出
                      Container(
                        decoration: BoxDecoration(color: Colors.transparent),
                        constraints: BoxConstraints.tightForFinite(width: 24.0),
                      ),

                      /// floating action bar
//                      Positioned(
//                        bottom: 16 + fabsBottom,
//                        left: 0,
//                        right: 0,
//                        child: Container(padding: EdgeInsets.symmetric(horizontal: 16), child: BottomFabsScenes()),
//                      ),
                      BottomFabsScenes(draggableBottomSheetController: _draggableBottomSheetController),

                      ///bottom sheet
                      DraggableBottomSheet(
                          controller: _draggableBottomSheetController,
                          childScrollController: _bottomSheetScrollController,
                          child: Column(
                            children: <Widget>[if (_selectedPoiEntity != null) PoiBottomSheet(_selectedPoiEntity) else SearchingBottomSheet()],
//                            children: <Widget>[SearchingBottomSheet()],
                          ))
                    ],
                  )),
        ));
  }

  Widget buildSearchWidget(context) {
    return Container(
      margin: EdgeInsets.only(top: 40, left: 16, right: 16),
      constraints: BoxConstraints.tightForFinite(height: 48),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        elevation: 2.0,
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Icon(Icons.menu, color: Colors.grey[600]),
              ),
            ),
            Expanded(
                child: GestureDetector(
              onTap: () async {
                var searchResult = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SearchPage(
                              searchCenter: LatLng(23.108317, 113.316121), //test TODO
                              searchText: _searchTextController.text,
//                          searchText: '中华人民共和国', //test
                            )));
                if (searchResult is String) {
                  _searchText(searchResult);
                } else if (searchResult is SearchPoiEntity) {
                  _showPoi(searchResult);
                }
              },
              child: Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                color: Colors.transparent,
                child: TextField(
                    controller: _searchTextController,
                    enabled: false,
                    decoration: InputDecoration(hintText: '搜索 / 解码', border: InputBorder.none),
                    style: Theme.of(context).textTheme.body1),
              ),
            )),
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            if (_isShowingSearch)
              InkWell(
                  onTap: () {
                    setState(() {
                      _isShowingSearch = false;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey[600],
                    ),
                  ))
          ],
        ),
      ),
    );
  }
}
