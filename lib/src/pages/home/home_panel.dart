
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/components/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/components/scaffold_map/map.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/global_data/global_data.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/widget/drag_tick.dart';

import '../contribution/contribution_tasks_page.dart';

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

                      // todo: test_jison_0426
                      print('[Home_panel] -->focusArea， 数组展示');
                      if (Platform.isIOS) {
                        // old version
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WebViewContainer(
                                  initUrl: 'https://news.hyn.space/react-reduction/',
                                  title: S.of(context).map3_global_nodes,
                                )));

                      } else {
                        // new version
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GlobalDataPage()));
                      }

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
                Application.router.navigateTo(context,Routes.contribute_tasks_list);
//                Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                    settings: RouteSettings(name: '/data_contribution_page'),
//                    builder: (context) => ContributionTasksPage(),
//                  ),
//                );
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
    var center = Application.recentlyLocation;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _buildPoiItem('res/drawable/ic_food.png', S.of(context).foods, onTap: () async {
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context).add(SearchTextEvent(
                isCategorySearch: true, gaodeType: 1, center: center, searchText: '美食', typeOfNearBy: "restaurant"));
          }
        }),
        _buildPoiItem('res/drawable/ic_hotel.png', S.of(context).hotel, onTap: () async {
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context).add(
                SearchTextEvent(isCategorySearch: true, gaodeType: 2, center: center, searchText: '酒店', typeOfNearBy: "lodging"));
          }
        }),
        _buildPoiItem('res/drawable/ic_scenic_spotx.png', S.of(context).attraction, onTap: () async {
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context).add(SearchTextEvent(
                isCategorySearch: true, gaodeType: 3, center: center, searchText: '景点', typeOfNearBy: "tourist_attraction"));
          }
        }),
        _buildPoiItem('res/drawable/ic_park.png', S.of(context).paking, onTap: () async {
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context).add(SearchTextEvent(
                isCategorySearch: true, gaodeType: 4, center: center, searchText: '停车场', typeOfNearBy: "parking"));
          }
        }),
        _buildPoiItem('res/drawable/ic_gas_station.png', S.of(context).gas_station, onTap: () async {
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context).add(SearchTextEvent(
                isCategorySearch: true, gaodeType: 5, center: center, searchText: '加油站', typeOfNearBy: "gas_station"));
          }
        }),
      ],
    );
  }

//  get mapCenter async {
//    var center =
//        await (Keys.mapContainerKey.currentState as MapContainerState)?.mapboxMapController?.getCameraPosition();
//    return center?.target;
//  }

  Widget poiRow2(context) {
    bool isChinaMainland = SettingInheritedModel.of(context).areaModel.isChinaMainland;
    var center = Application.recentlyLocation;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _buildPoiItem('res/drawable/ic_bank.png', S.of(context).bank, onTap: () async {
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context).add(
                SearchTextEvent(isCategorySearch: true, gaodeType: 6, center: center, searchText: '银行', typeOfNearBy: "bank"));
          }
        }),
        _buildPoiItem('res/drawable/ic_supermarket.png', S.of(context).supermarket, onTap: () async {
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context).add(SearchTextEvent(
                isCategorySearch: true, gaodeType: 7, center: center, searchText: '超市', typeOfNearBy: "grocery_or_supermarket"));
          }
        }),
        _buildPoiItem('res/drawable/ic_market.png', S.of(context).mall, onTap: () async {
          if (center != null) {
            BlocProvider.of<ScaffoldMapBloc>(context).add(SearchTextEvent(
                isCategorySearch: true, gaodeType: 8, center: center, searchText: '商场', typeOfNearBy: "shopping_mall"));
          }
        }),
        if (isChinaMainland)
          _buildPoiItem('res/drawable/ic_cybercafe.png', S.of(context).internet_bar, onTap: () async {
            if (center != null) {
              BlocProvider.of<ScaffoldMapBloc>(context).add(
                  SearchTextEvent(isCategorySearch: true, gaodeType: 9, center: center, searchText: '网吧', typeOfNearBy: "cafe"));
            }
          }),
        if (isChinaMainland)
          _buildPoiItem('res/drawable/ic_wc.png', S.of(context).toilet, onTap: () async {
            if (center != null) {
              BlocProvider.of<ScaffoldMapBloc>(context).add(SearchTextEvent(
                  isCategorySearch: true, gaodeType: 10, center: center, searchText: '厕所', typeOfNearBy: "night_club"));
            }
          }),
        if (!isChinaMainland)
          _buildPoiItem('res/drawable/ic_cafe.png', S.of(context).cafe, onTap: () async {
            if (center != null) {
              BlocProvider.of<ScaffoldMapBloc>(context).add(
                  SearchTextEvent(isCategorySearch: true, gaodeType: 9, center: center, searchText: '咖啡馆', typeOfNearBy: "cafe"));
            }
          }),
        if (!isChinaMainland)
          _buildPoiItem('res/drawable/ic_hospital.png', S.of(context).hospital, onTap: () async {
            if (center != null) {
              BlocProvider.of<ScaffoldMapBloc>(context).add(SearchTextEvent(
                  isCategorySearch: true, gaodeType: 10, center: center, searchText: '医院', typeOfNearBy: "hospital"));
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
    Application.eventBus.fire(GoSearchEvent());
  }
}
