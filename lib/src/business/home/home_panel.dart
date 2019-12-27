import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/business/me/contract/buy_hash_rate_page_v2.dart';
import 'package:titan/src/business/me/my_asset_page.dart';
import 'package:titan/src/business/me/my_hash_rate_page.dart';
import 'package:titan/src/business/me/my_node_mortgage_page.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/me/user_info_state.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/my/app_area.dart';
import 'package:titan/src/business/scaffold_map/map.dart';
import 'package:titan/src/business/webview/webview.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/widget/drag_tick.dart';
import 'package:titan/src/inject/injector.dart';
import 'package:titan/src/model/dianping_poi.dart';
import 'package:titan/src/utils/coord_convert.dart';
import 'dart:math' as math;

import 'package:fake_cookie_manager/fake_cookie_manager.dart' as fake;
import 'package:titan/src/utils/utils.dart';

import '../../global.dart';
import '../scaffold_map/bloc/bloc.dart';
import 'data_contribution_page.dart';

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
    setDianpingCookies();
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  void eventBusListener(event) async {
    if (event is OnMapMovedEvent) {
      loadCityRecommend(event.latLng);
    }
  }

  void loadCityRecommend(LatLng latLng) async {
    if (/*nearPois.length == 0 && */ (lastPosition == null || lastPosition.distanceTo(latLng) > 5000)) {
      lastPosition = latLng;
      var latlng = CoordConvert.wgs84togcj02(Coords(latLng.latitude, latLng.longitude));
      var pois = await Injector.of(context).repository.requestDianping(latlng.latitude, latlng.longitude);
      if (pois.length > 0) {
        setState(() {
          nearPois = pois;
        });
      }
    }
  }

  Future setDianpingCookies() async {
    String cookies = await _userService.getDianpingCookies();
    var cookie = Cookie.fromSetCookieValue('_lxsdk_cuid=$cookies');
    await fake.CookieManager.saveCookies(url: 'm.dianping.com', cookies: [cookie]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20.0,
          ),
        ],
      ),
      child: CustomScrollView(
        controller: widget.scrollController,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 12),
                  child: DragTick(),
                ),
              ],
            ),
          ),
          /* 搜索 */
          SliverToBoxAdapter(
            child: _search(),
          ),
          /* 模式 */
//          SliverToBoxAdapter(
//            child: _mode(context),
//          ),
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
          if (currentAppArea.key == AppArea.MAINLAND_CHINA_AREA.key)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 4),
                child: InkWell(
                  onTap: () async {
//                  await fake.CookieManager.clearAllCookies();
//                  Fluttertoast.showToast(msg: '清除cookie成功');

//                  var html = await HttpCore.instance.get('https://m.dianping.com/', options: RequestOptions(
//                    headers: {
//                      'User-Agent':
//                      'Mozilla/5.0 (Linux; Android 8.0; Pixel 2 Build/OPD3.170816.012) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Mobile Safari/537.36',
//                    }
//                  ));
//                  print(html);

//
//                  var cookies = await fake.CookieManager.loadCookies(url: 'm.dianping.com');
//                  print('>>>---' * 10);
//                  for(var cookie in cookies) {
//                    print(cookie);
//                  }
//                  print('<<<---' * 10);
                  },
                  child: Text(
                    S.of(context).city_recommendation,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          //hack webview， just what is's cookie...
          if (currentAppArea.key == AppArea.MAINLAND_CHINA_AREA.key)
            SliverToBoxAdapter(
              child: Stack(
                children: <Widget>[
                  Container(
                    height: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          if (currentAppArea.key == AppArea.MAINLAND_CHINA_AREA.key)
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
      borderRadius: BorderRadius.all(Radius.circular(32)),
      child: Container(
        height: 46,
        decoration: BoxDecoration(color: Color(0xfff4f4fa), borderRadius: BorderRadius.all(Radius.circular(32))),
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
              S.of(context).search_or_decode,
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
                      "${Const.DOUBLE_NUMBER_FORMAT.format(Utils.powerForShow(LOGIN_USER_INFO.totalPower))}",
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => BuyHashRatePageV2()));
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
      margin: EdgeInsets.only(top: 16),
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
                                    title: S.of(context).map3_global_nodes,
                                  )));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          border: Border.all(color: Color(0xFFE9E9E9), width: 1)),
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, left: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  S.of(context).global_nodes,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0, right: 4),
                                  child: Text(
                                    S.of(context).global_map_server_nodes,
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                              top: 12,
                              right: 12,
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
                  height: 8,
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WebViewContainer(
                                    initUrl: S.of(context).hyperion_project_intro_url,
                                    title: S.of(context).Hyperion,
                                  )));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          border: Border.all(color: Color(0xFFE9E9E9), width: 1)),
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, left: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  S.of(context).Hyperion,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    S.of(context).project_introduction,
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                              top: 8,
                              right: 8,
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
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: RouteSettings(name: '/data_contribution_page'),
                    builder: (context) => DataContributionPage(),
                  ),
                );
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
                            S.of(context).data_contribute,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              S.of(context).data_contribute_reward,
                              style: TextStyle(color: Colors.grey, fontSize: 12),
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
          ),
        ],
      ),
    );
  }

  Widget poiRow1(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _buildPoiItem('res/drawable/ic_food.png', S.of(context).foods, onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context).add(SearchTextEvent(
                isGaodeSearch: true, type: 1, center: center, searchText: '美食', stringType: "restaurant"));
          }
        }),
        _buildPoiItem('res/drawable/ic_hotel.png', S.of(context).hotel, onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context).add(
                SearchTextEvent(isGaodeSearch: true, type: 2, center: center, searchText: '酒店', stringType: "lodging"));
          }
        }),
        _buildPoiItem('res/drawable/ic_scenic_spotx.png', S.of(context).attraction, onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context).add(SearchTextEvent(
                isGaodeSearch: true, type: 3, center: center, searchText: '景点', stringType: "tourist_attraction"));
          }
        }),
        _buildPoiItem('res/drawable/ic_park.png', S.of(context).paking, onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context).add(SearchTextEvent(
                isGaodeSearch: true, type: 4, center: center, searchText: '停车场', stringType: "parking"));
          }
        }),
        _buildPoiItem('res/drawable/ic_gas_station.png', S.of(context).gas_station, onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context).add(SearchTextEvent(
                isGaodeSearch: true, type: 5, center: center, searchText: '加油站', stringType: "gas_station"));
          }
        }),
      ],
    );
  }

  get mapCenter async {
    var center =
        await (Keys.mapContainerKey.currentState as MapContainerState)?.mapboxMapController?.getCameraPosition();
    return center?.target;
  }

  Widget poiRow2(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _buildPoiItem('res/drawable/ic_bank.png', S.of(context).bank, onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context).add(
                SearchTextEvent(isGaodeSearch: true, type: 6, center: center, searchText: '银行', stringType: "bank"));
          }
        }),
        _buildPoiItem('res/drawable/ic_supermarket.png', S.of(context).supermarket, onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context).add(SearchTextEvent(
                isGaodeSearch: true, type: 7, center: center, searchText: '超市', stringType: "grocery_or_supermarket"));
          }
        }),
        _buildPoiItem('res/drawable/ic_market.png', S.of(context).mall, onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context).add(SearchTextEvent(
                isGaodeSearch: true, type: 8, center: center, searchText: '商场', stringType: "shopping_mall"));
          }
        }),
        if (currentAppArea.key == AppArea.MAINLAND_CHINA_AREA.key)
          _buildPoiItem('res/drawable/ic_cybercafe.png', S.of(context).internet_bar, onTap: () async {
            var center = await mapCenter;
            if (center != null) {
              BlocProvider.of<ScaffoldMapBloc>(context).add(
                  SearchTextEvent(isGaodeSearch: true, type: 9, center: center, searchText: '网吧', stringType: "cafe"));
            }
          }),
        if (currentAppArea.key == AppArea.MAINLAND_CHINA_AREA.key)
          _buildPoiItem('res/drawable/ic_wc.png', S.of(context).toilet, onTap: () async {
            var center = await mapCenter;
            if (center != null) {
              BlocProvider.of<ScaffoldMapBloc>(context).add(SearchTextEvent(
                  isGaodeSearch: true, type: 10, center: center, searchText: '厕所', stringType: "night_club"));
            }
          }),
        if (currentAppArea.key != AppArea.MAINLAND_CHINA_AREA.key)
          _buildPoiItem('res/drawable/ic_cafe.png', S.of(context).cafe, onTap: () async {
            var center = await mapCenter;
            if (center != null) {
              BlocProvider.of<ScaffoldMapBloc>(context).add(
                  SearchTextEvent(isGaodeSearch: true, type: 9, center: center, searchText: '咖啡馆', stringType: "cafe"));
            }
          }),
        if (currentAppArea.key != AppArea.MAINLAND_CHINA_AREA.key)
          _buildPoiItem('res/drawable/ic_hospital.png', S.of(context).hospital, onTap: () async {
            var center = await mapCenter;
            if (center != null) {
              BlocProvider.of<ScaffoldMapBloc>(context).add(SearchTextEvent(
                  isGaodeSearch: true, type: 10, center: center, searchText: '医院', stringType: "hospital"));
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
