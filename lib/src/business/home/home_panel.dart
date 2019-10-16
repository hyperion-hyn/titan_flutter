import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/business/infomation/info_detail_page.dart';
import 'package:titan/src/business/me/buy_hash_rate_page.dart';
import 'package:titan/src/business/me/my_asset_page.dart';
import 'package:titan/src/business/me/my_hash_rate_page.dart';
import 'package:titan/src/business/me/my_node_mortgage_page.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/me/user_info_state.dart';
import 'package:titan/src/business/scaffold_map/map.dart';
import 'package:titan/src/business/webview/webview.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/inject/injector.dart';
import 'package:titan/src/model/dianping_poi.dart';
import 'package:titan/src/utils/coord_convert.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math' as math;

import '../../global.dart';
import '../scaffold_map/bloc/bloc.dart';

class HomePanel extends StatefulWidget {
  final ScrollController scrollController;

  HomePanel({this.scrollController});

  @override
  State<StatefulWidget> createState() {
    return HomePanelState();
  }
}

class HomePanelState extends UserState<HomePanel> {
  UserService _userService = UserService();

  //附近的推荐
  List<DianPingPoi> nearPois = [];

  LatLng lastPosition;

  StreamSubscription streamSubscription;

  @override
  void initState() {
    super.initState();
    streamSubscription = eventBus.on().listen(eventBusListener);
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  void eventBusListener(event) async {
    if (event is OnMapMovedEvent) {
      print('xxx1 ${event.latLng}');
      if (lastPosition == null || lastPosition.distanceTo(event.latLng) > 200) {
        lastPosition = event.latLng;
        var latlng = CoordConvert.wgs84togcj02(Coords(event.latLng.latitude, event.latLng.longitude));
        print('xxx2 ${latlng.latitude}, ${latlng.longitude}');
        var pois = await Injector.of(context).repository.requestDianping(latlng.latitude, latlng.longitude);
        print('xxx3 ${pois}');
        if (pois.length > 0) {
          setState(() {
            nearPois = pois;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: CustomScrollView(
        controller: widget.scrollController,
        slivers: <Widget>[
          /* 搜索 */
          SliverToBoxAdapter(
            child: _search(),
          ),
          /* 模式 */
          SliverToBoxAdapter(
            child: _mode(context),
          ),
          SliverToBoxAdapter(
            child: focusArea(context),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: <Widget>[
                  poiRow1(context),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: poiRow2(context),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 16),
              child: Text(
                '城市推荐',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          //hack webview， just what is's cookie...
          SliverToBoxAdapter(
            child: Container(
              height: 0,
              child: WebView(
                initialUrl: 'https://m.dianping.com/',
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final int itemIndex = index ~/ 2;
                    if (index.isEven) {
                      var poi = nearPois[itemIndex];
                      return _buildRecommendItem(context, poi);
                    } else {
                      //devicer
                      return Divider(height: 0);
                    }
                  },
                  childCount: _computeSemanticChildCount(nearPois.length),
                  semanticIndexCallback: (Widget _, int index) {
                    return index.isEven ? index ~/ 2 : null;
                  })),
        ],
      ),
    );
  }

  Widget _search() {
    return InkWell(
      onTap: onSearch,
      borderRadius: BorderRadius.all(Radius.circular(31)),
      child: Ink(
        height: 44,
        decoration: BoxDecoration(color: Color(0xfffff4f4fa), borderRadius: BorderRadius.all(Radius.circular(31))),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 8),
              child: Icon(
                Icons.search,
                color: Color(0xff8193AE),
              ),
            ),
            Text(
              '搜索',
              style: TextStyle(
                color: Color(0xff8193AE),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mode(context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyAssetPage()));
                },
                child: Column(
                  children: <Widget>[
                    Text(
                      "${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.balance)}",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        '我的账户(USDT)',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyHashRatePage()));
                },
                child: Column(
                  children: <Widget>[
                    Text(
                      "${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.totalPower)}",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        '我的算力(T)',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyNodeMortgagePage()));
                },
                child: Column(
                  children: <Widget>[
                    Text(
                      "${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.mortgageNodes)}",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        '节点抵押(USDT)',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32.0, left: 16, right: 16),
            child: InkWell(
              onTap: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context) => BuyHashRatePage()));
              },
              child: Ink(
                height: 42,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor, borderRadius: BorderRadius.all(Radius.circular(31))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('res/drawable/rock.png', width: 16.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        '获得算力',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget focusArea(context) {
    return Container(
      margin: EdgeInsets.only(top: 32),
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WebViewContainer(
                                    initUrl: 'https://news.hyn.space/react-reduction/',
                                    title: 'map3全球节点',
                                  )));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          border: Border.all(color: Color(0xFFE9E9E9), width: 1)),
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0, left: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '全球节点',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    '全球地图服务节点',
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                              top: 15,
                              right: 15,
                              child: Image.asset(
                                'res/drawable/global.png',
                                width: 32,
                                height: 32,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WebViewContainer(
                                    initUrl: 'https://shimo.im/docs/GDp72cj3ATwEB7ke/read',
                                    title: '海伯利安',
                                  )));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          border: Border.all(color: Color(0xFFE9E9E9), width: 1)),
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0, left: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '海伯利安',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    '项目介绍',
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                              top: 15,
                              right: 15,
                              child: Image.asset(
                                'res/drawable/ic_hyperion.png',
                                width: 32,
                                height: 32,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  border: Border.all(color: Color(0xFFE9E9E9), width: 1)),
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '数据贡献',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '贡献地图数据获得HYN奖励',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '即将开放',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFFF82530)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                      top: 36,
                      right: 16,
                      child: Image.asset(
                        'res/drawable/data.png',
                        width: 32,
                        height: 32,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget poiRow1(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _buildPoiItem('res/drawable/ic_food.png', '美食', onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context)
                .dispatch(SearchTextEvent(isGaodeSearch: true, type: 1, center: center, searchText: '美食'));
          }
        }),
        _buildPoiItem('res/drawable/ic_hotel.png', '酒店', onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context)
                .dispatch(SearchTextEvent(isGaodeSearch: true, type: 2, center: center, searchText: '酒店'));
          }
        }),
        _buildPoiItem('res/drawable/ic_scenic_spotx.png', '景点', onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context)
                .dispatch(SearchTextEvent(isGaodeSearch: true, type: 3, center: center, searchText: '景点'));
          }
        }),
        _buildPoiItem('res/drawable/ic_park.png', '停车场', onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context)
                .dispatch(SearchTextEvent(isGaodeSearch: true, type: 4, center: center, searchText: '停车场'));
          }
        }),
        _buildPoiItem('res/drawable/ic_gas_station.png', '加油站', onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context)
                .dispatch(SearchTextEvent(isGaodeSearch: true, type: 5, center: center, searchText: '加油站'));
          }
        }),
      ],
    );
  }

  get mapCenter async {
    var center = await (Keys.mapKey.currentState as MapContainerState)?.mapboxMapController?.getCameraPosition();
    return center?.target;
  }

  Widget poiRow2(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _buildPoiItem('res/drawable/ic_bank.png', '银行', onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context)
                .dispatch(SearchTextEvent(isGaodeSearch: true, type: 6, center: center, searchText: '银行'));
          }
        }),
        _buildPoiItem('res/drawable/ic_supermarket.png', '超市', onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context)
                .dispatch(SearchTextEvent(isGaodeSearch: true, type: 7, center: center, searchText: '超市'));
          }
        }),
        _buildPoiItem('res/drawable/ic_market.png', '商场', onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context)
                .dispatch(SearchTextEvent(isGaodeSearch: true, type: 8, center: center, searchText: '商场'));
          }
        }),
        _buildPoiItem('res/drawable/ic_cybercafe.png', '网吧', onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context)
                .dispatch(SearchTextEvent(isGaodeSearch: true, type: 9, center: center, searchText: '网吧'));
          }
        }),
        _buildPoiItem('res/drawable/ic_wc.png', '厕所', onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context)
                .dispatch(SearchTextEvent(isGaodeSearch: true, type: 10, center: center, searchText: '厕所'));
          }
        }),
      ],
    );
  }

  Widget _buildPoiItem(String asset, String label, {GestureTapCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              Image.asset(
                asset,
                color: Theme.of(context).primaryColor,
                width: 32,
                height: 32,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  label,
                  style: TextStyle(fontSize: 12),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to compute the semantic child count for the separated constructor.
  static int _computeSemanticChildCount(int itemCount) {
    return math.max(0, itemCount * 2 - 1);
  }

  Widget _buildRecommendItem(context, DianPingPoi poi) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
//            print('poi item click');
//            if (await canLaunch(poi.schema)) {
//              await launch(poi.schema);
//            } else {
//              print('Could not launch ${poi.schema}');
//            }
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WebViewContainer(
                          initUrl: poi.schema,
                          title: poi.shopName,
//                      userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1 Mobile/15E148 Safari/604.1',
                        )));
          },
          child: Ink(
            child: Row(
//            crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.network(
                  poi.defaultPic,
                  height: 78,
                  width: 110,
                  fit: BoxFit.cover,
                ),
                Expanded(
                  child: Container(
//                color: Colors.red,
                    margin: EdgeInsets.only(left: 16, right: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          poi.shopName,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  poi.dealGroupTitle,
                                  style: TextStyle(fontSize: 13, color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onSearch() async {
    eventBus.fire(GoSearchEvent());
  }
}
