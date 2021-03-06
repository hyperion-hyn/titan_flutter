import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/scaffold_map/dmap/dmap.dart';
import 'package:titan/src/data/entity/poi/poi_interface.dart';
import 'package:titan/src/pages/discover/bloc/bloc.dart';
import 'package:titan/src/components/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/pages/discover/dapp/police_service/model.dart';
import 'package:titan/src/pages/discover/dapp/police_service/police_station_panel.dart';
import 'package:titan/src/utils/map_util.dart';

final policeDMapConfigModel = DMapConfigModel(
    dMapName: 'policeStation',
    heavenDataModelList: <HeavenDataModel>[
      HeavenDataModel(
        id: '3818230e27554203b638851aa246e7d3',
        sourceLayer: 'police',
        sourceUrl: "https://store.tile.map3.network/maps/global/police/{z}/{x}/{y}.vector.pbf",
        color: 0xff836FFF,
      )
    ],
    defaultLocation: LatLng(22.296797, 114.170900),
    defaultZoom: 12,
    onMapClickHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
      var poi;
      var feature = await MapUtil.getFeature(point, coordinates, 'layer-heaven-3818230e27554203b638851aa246e7d3');
      if (feature != null) {
        poi = PoliceStationPoi.fromMapFeature(feature);
        if (poi != null) {
          BlocProvider.of<ScaffoldMapBloc>(context).add(ShowPoiEvent(poi: poi));
        }
      }
//      if (poi == null) {
//        BlocProvider.of<ScaffoldMapBloc>(context).add(ClearSelectedPoiEvent());
//      }
      return true;
    },
    onMapLongPressHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
      print('on long press police');
      return true;
    },

    // todo:jison_add
//    alwaysShowPanel: false,
//    panelDraggable: false,
//    showCenterMarker: false,
//    panelPaddingTop: (context) => MediaQuery.of(context).size.height * 0.45,
//    panelAnchorHeight: (context) => MediaQuery.of(context).size.height,
//    panelCollapsedHeight: (context) => 20,

    panelBuilder: (BuildContext context, ScrollController scrollController, IDMapPoi poi) {
      return PoliceStationPanel(poi: poi, scrollController: scrollController);
    },
    panelPaddingTop: (context) => MediaQuery.of(context).padding.top + 56 - 12 //减去drag的高度
    );

class PoliceService extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PoliceServiceState();
  }
}

class PoliceServiceState extends State<PoliceService> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScaffoldMapBloc, ScaffoldMapState>(
      bloc: BlocProvider.of<ScaffoldMapBloc>(context),
      builder: (context, state) {
        return Stack(
          fit: StackFit.loose,
          children: <Widget>[
            Container(), //need a container to expand.
            //top bar
            if (state is! FocusingRouteState)
              Container(
                height: MediaQuery.of(context).padding.top + 56,
                child: BaseAppBar(
                  leading: Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          BlocProvider.of<DiscoverBloc>(context).add(InitDiscoverEvent());
                        },
                      );
                    },
                  ),

                  baseTitle: S.of(context).police_security_station,
                ),
              ),
          ],
        );
      },
    );
  }
}
