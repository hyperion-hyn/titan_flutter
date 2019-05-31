import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/webview/webview.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/widget/smart_drawer.dart';

import 'package:toast/toast.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LatLng center = const LatLng(23.122592, 113.327356);

  StreamSubscription _subscription;

  _onMapCreated(MapboxMapController controller) {
    print('map created');
  }

  @override
  void initState() {
    _subscription = TitanPlugin.listenCipherEvent((data) {
      print(data);
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Builder(builder: (BuildContext ctx) => _drawer(ctx)),
        body: Builder(
            builder: (BuildContext ctx) => Stack(
                  children: <Widget>[
                    ///地图渲染
                    _mapbox,

                    ///搜索入口
                    Container(
                      margin: EdgeInsets.only(top: 56, left: 32, right: 32),
                      constraints: BoxConstraints.tightForFinite(height: 48),
                      decoration: BoxDecoration(color: Color(0xccffffff), borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () => Scaffold.of(ctx).openDrawer(),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 16),
                              child: Icon(Icons.menu, color: Colors.black45),
                            ),
                          ),
                          Flexible(
                              child: TextField(
                                  enabled: false,
                                  decoration: InputDecoration(hintText: '搜索 / 解码', border: InputBorder.none),
                                  style: Theme.of(context).textTheme.body1))
                        ],
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
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: <Widget>[
                            FloatingActionButton(
                              onPressed: () => _showFireModalBottomSheet(ctx),
                              mini: true,
                              heroTag: 'cleanData',
                              backgroundColor: Colors.white,
                              child: Image.asset(
                                'res/drawable/ic_logo.png',
                                width: 24,
                                color: Colors.black54,
                              ),
                            ),
                            Spacer(),
                            FloatingActionButton(
                              onPressed: () {
                                Toast.show('TODO 定位', context);
                              },
                              mini: true,
                              heroTag: 'myLocation',
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.my_location,
                                color: Colors.black54,
                                size: 24,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                )));
  }

  Widget _drawer(BuildContext context) {
    return SmartDrawer(
      widthPercent: 0.72,
      callback: (isOpen) {
        print('drawer state: $isOpen');
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                gradient:
                    LinearGradient(colors: [Color(0xff212121), Color(0xff000000)], begin: FractionalOffset(0, 0.4), end: FractionalOffset(0, 1))),
            height: 200.0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Image.asset('res/drawable/ic_logo.png', width: 40.0),
                        SizedBox(width: 8),
                        Image.asset('res/drawable/logo_title.png', width: 72.0)
                      ],
                    ),
                    SizedBox(height: 16),
                    Text('我的隐私地图', style: TextStyle(color: Colors.white70))
                  ],
                ),
              ),
            ),
          ),
          ListTile(
            onTap: () => print('TODO'),
            leading: Icon(Icons.lock),
            title: Text('我的加密地址(公钥)'),
            trailing: Icon(Icons.navigate_next),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.all(8),
            color: Colors.grey[200],
            child: GestureDetector(
              onTap: () {
//                Toast.show('TODO copy', context, duration: Toast.LENGTH_LONG);
                Scaffold.of(context).showSnackBar(SnackBar(content: Text('TODO copy content')));
              },
              child: Row(
                children: <Widget>[
                  Flexible(
                      child: Text(
                    '1' + 'f' * 256 + '2',
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  )),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.content_copy,
                      size: 16,
                      color: Colors.black45,
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('23小时5分后自动刷新', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          Container(height: 8, color: Colors.grey[100]),
          ListTile(
            onTap: () {
              print('test cancel');
              _subscription?.cancel();
            },
            leading: Icon(Icons.map),
            title: Text(S.of(context).offline_map),
            trailing: Icon(Icons.navigate_next),
          ),
          Container(height: 8, color: Colors.grey[100]),
          ListTile(
            onTap: () async {
              var greet = await TitanPlugin.greetNative();
              print(greet);
            },
            leading: Icon(Icons.share),
            title: Text('分享App'),
            trailing: Icon(Icons.navigate_next),
          ),
          Container(height: 1, color: Colors.grey[100]),
          ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                return WebViewPage();
              }));
            },
            leading: Icon(Icons.info),
            title: Text('关于我们'),
            trailing: Icon(Icons.navigate_next),
          )
        ],
      ),
    );
  }

  get _mapbox => MapboxMap(
        styleString: 'https://static.hyn.space/maptiles/see-it-all.json',
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: center,
          zoom: 9.0,
        ),
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
      );

  void _showFireModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            margin: EdgeInsets.all(8),
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(IconData(0xe66e, fontFamily: 'iconfont'), color: Color(0xffac2229)),
                    title: new Text('清除痕迹', style: TextStyle(color: Color(0xffac2229), fontWeight: FontWeight.w500)),
                    onTap: () {
                      Toast.show('TODO', ctx);
                      Navigator.pop(ctx);
                    }),
                new ListTile(
                  leading: new Icon(Icons.close),
                  title: new Text('取消'),
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          );
        });
  }
}
