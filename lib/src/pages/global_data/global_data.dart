
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/scaffold_map/dmap/dmap.dart';
import 'package:titan/src/data/entity/poi/poi_interface.dart';
import 'package:titan/src/pages/discover/dapp/police_service/police_station_panel.dart';
import 'package:titan/src/pages/global_data/echarts/signal_chart.dart';


//POI服务站
final poiDMapConfigModel = DMapConfigModel(
    dMapName: 'poi',
    heavenDataModelList: <HeavenDataModel>[
      HeavenDataModel(
        id: '3818230e27554203b638851aa246e7d3',
        sourceLayer: 'poi',
        sourceUrl: "https://store.tile.map3.network/tile/contribution/poi/{z}/{x}/{y}.pbf",
        color: 0xff836FFF,
      )
    ],
    defaultLocation: LatLng(22.296797, 114.170900),
    defaultZoom: 12,

    onMapLongPressHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
      print('on long press police');
      return true;
    },
    panelBuilder: (BuildContext context, ScrollController scrollController, IDMapPoi poi) {
      return PoliceStationPanel(poi: poi, scrollController: scrollController);
    },
    panelPaddingTop: (context) => MediaQuery.of(context).padding.top + 56 - 12 //减去drag的高度
);

class GlobalDataPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GlobalDataState();
  }
}

class _GlobalDataState extends State<GlobalDataPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        baseTitle: S.of(context).global_data,
        backgroundColor: Colors.white,
      ),

      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              child: Material(
                elevation: 3,
                child: SafeArea(
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: TabBar(
                            labelColor: Colors.black,
                            labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                            indicatorSize: TabBarIndicatorSize.label,
                            indicatorColor: Theme.of(context).primaryColor,
                            indicatorWeight: 5,
                            unselectedLabelColor: Colors.grey[400],
                            tabs: [
                              Tab(
                                text: S.of(context).global_data_map3,
                              ),
                              Tab(
                                text: S.of(context).global_data_signal,
                              ),
                              Tab(
                                text: S.of(context).global_data_poi,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              SignalChatsPage(type: SignalChatsPage.NODE),
              SignalChatsPage(type: SignalChatsPage.SIGNAL),
              SignalChatsPage(type: SignalChatsPage.POI),
            ],
            //physics: NeverScrollableScrollPhysics(),
          ),
        ),
      ),
    );
  }
}
