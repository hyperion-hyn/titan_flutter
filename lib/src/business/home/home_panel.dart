import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/business/scaffold_map/map.dart';
import 'package:titan/src/business/webview/webview.dart';
import 'package:titan/src/consts/consts.dart';

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

class HomePanelState extends State<HomePanel> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
              '搜索 / 解码位置密文',
              style: TextStyle(
                color: Color(0xff8193AE),
              ),
            ),
          ],
        ),
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
                .add(SearchTextEvent(isGaodeSearch: true, type: 1, center: center, searchText: '美食'));
          }
        }),
        _buildPoiItem('res/drawable/ic_hotel.png', '酒店', onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context)
                .add(SearchTextEvent(isGaodeSearch: true, type: 2, center: center, searchText: '酒店'));
          }
        }),
        _buildPoiItem('res/drawable/ic_scenic_spotx.png', '景点', onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context)
                .add(SearchTextEvent(isGaodeSearch: true, type: 3, center: center, searchText: '景点'));
          }
        }),
        _buildPoiItem('res/drawable/ic_park.png', '停车场', onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context)
                .add(SearchTextEvent(isGaodeSearch: true, type: 4, center: center, searchText: '停车场'));
          }
        }),
        _buildPoiItem('res/drawable/ic_gas_station.png', '加油站', onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context)
                .add(SearchTextEvent(isGaodeSearch: true, type: 5, center: center, searchText: '加油站'));
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
                .add(SearchTextEvent(isGaodeSearch: true, type: 6, center: center, searchText: '银行'));
          }
        }),
        _buildPoiItem('res/drawable/ic_supermarket.png', '超市', onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context)
                .add(SearchTextEvent(isGaodeSearch: true, type: 7, center: center, searchText: '超市'));
          }
        }),
        _buildPoiItem('res/drawable/ic_market.png', '商场', onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context)
                .add(SearchTextEvent(isGaodeSearch: true, type: 8, center: center, searchText: '商场'));
          }
        }),
        _buildPoiItem('res/drawable/ic_cybercafe.png', '网吧', onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context)
                .add(SearchTextEvent(isGaodeSearch: true, type: 9, center: center, searchText: '网吧'));
          }
        }),
        _buildPoiItem('res/drawable/ic_wc.png', '厕所', onTap: () async {
          var center = await mapCenter;
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context)
                .add(SearchTextEvent(isGaodeSearch: true, type: 10, center: center, searchText: '厕所'));
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

  void onSearch() async {
    eventBus.fire(GoSearchEvent());
  }
}
