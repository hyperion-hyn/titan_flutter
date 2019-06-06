import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:titan/src/business/search/search_page.dart';
import 'package:toast/toast.dart';

import 'map_scenes.dart';
import 'bottom_fabs_scenes.dart';
import 'drawer_scenes.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _lastPressedAt;

  final TextEditingController _searchTextController = TextEditingController();

  bool _isSearching = false;
  bool _isShowingSearch = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: DrawerScenes(),
        body: WillPopScope(
          onWillPop: () async {
            if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt) > Duration(seconds: 2)) {
              _lastPressedAt = DateTime.now();
              Toast.show('再点击一次退出', context, duration: Toast.LENGTH_LONG);
              return false;
            }
            return true;
          },
          child: Builder(
              builder: (BuildContext ctx) => Stack(
                    children: <Widget>[
                      ///地图渲染
                      MapScenes(),

                      ///搜索入口
                      Container(
                        margin: EdgeInsets.only(top: 40, left: 16, right: 16),
                        constraints: BoxConstraints.tightForFinite(height: 48),
                        child: Material(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          elevation: 2.0,
                          child: Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () => Scaffold.of(ctx).openDrawer(),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16, right: 8),
                                  child: Icon(Icons.menu, color: Colors.grey[600]),
                                ),
                              ),
                              Expanded(
                                  child: GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));
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
                      ),

                      ///主要是支持drawer手势划出
                      Container(
                        decoration: BoxDecoration(color: Colors.transparent),
                        constraints: BoxConstraints.tightForFinite(width: 24.0),
                      ),

                      /// floating action bar
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Container(padding: EdgeInsets.symmetric(horizontal: 16), child: BottomFabsScenes()),
                      )
                    ],
                  )),
        ));
  }
}
