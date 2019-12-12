import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/my/app_area.dart';
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
                            padding: const EdgeInsets.only(top: 16.0, left: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  S.of(context).global_nodes,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    S.of(context).global_map_server_nodes,
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
                            padding: const EdgeInsets.only(top: 16.0, left: 8),
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
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            S.of(context).coming_soon,
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
        if (currentAppArea.key==AppArea.MAINLAND_CHINA_AREA.key)
          _buildPoiItem('res/drawable/ic_cybercafe.png', S.of(context).internet_bar, onTap: () async {
            var center = await mapCenter;
            if (center != null) {
              BlocProvider.of<ScaffoldMapBloc>(context).add(
                  SearchTextEvent(isGaodeSearch: true, type: 9, center: center, searchText: '网吧', stringType: "cafe"));
            }
          }),
        if (currentAppArea.key==AppArea.MAINLAND_CHINA_AREA.key)
          _buildPoiItem('res/drawable/ic_wc.png', S.of(context).toilet, onTap: () async {
            var center = await mapCenter;
            if (center != null) {
              BlocProvider.of<ScaffoldMapBloc>(context).add(SearchTextEvent(
                  isGaodeSearch: true, type: 10, center: center, searchText: '厕所', stringType: "night_club"));
            }
          }),
        if (currentAppArea.key!=AppArea.MAINLAND_CHINA_AREA.key)
          _buildPoiItem('res/drawable/ic_cafe.png', S.of(context).cafe, onTap: () async {
            var center = await mapCenter;
            if (center != null) {
              BlocProvider.of<ScaffoldMapBloc>(context).add(
                  SearchTextEvent(isGaodeSearch: true, type: 9, center: center, searchText: '咖啡馆', stringType: "cafe"));
            }
          }),
        if (currentAppArea.key!=AppArea.MAINLAND_CHINA_AREA.key)
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

  void onSearch() async {
    eventBus.fire(GoSearchEvent());
  }
}
