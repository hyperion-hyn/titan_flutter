import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/components/scaffold_map/dmap/dmap.dart';
import 'package:titan/src/data/entity/poi/poi_interface.dart';
import 'package:titan/src/pages/discover/bloc/bloc.dart';
import 'package:titan/src/pages/discover/dapp/embassy/embassy_poi_panel.dart';
import 'package:titan/src/pages/discover/dapp/embassy/entities.dart';
import 'package:titan/src/utils/map_util.dart';

final embassyDMapConfigModel = DMapConfigModel(
    dMapName: 'embassy',
    heavenDataModelList: <HeavenDataModel>[
      HeavenDataModel(
        id: 'c1b7c5102eca43029f0416892447e0ed',
        sourceLayer: 'embassy',
        sourceUrl: "https://store.tile.map3.network/maps/global/embassy/{z}/{x}/{y}.vector.pbf",
        color: 0xff59B45F,
      )
    ],
    defaultLocation: LatLng(22.296797, 114.170900),
    defaultZoom: 12,
    onMapClickHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
      print('【D-map] --> point:$point, coordinates:$coordinates');

      var poi;
      var feature = await MapUtil.getFeature(point, coordinates, 'layer-heaven-c1b7c5102eca43029f0416892447e0ed');

      if (feature != null) {
        poi = EmbassyPoi.fromMapFeature(feature);
        if (poi != null) {
          BlocProvider.of<ScaffoldMapBloc>(context).add(ShowPoiEvent(poi: poi));
        }
      }
      return true;
    },
    onMapLongPressHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
      print('on long press embassy');
      return true;
    },
    panelBuilder: (BuildContext context, ScrollController scrollController, IDMapPoi poi) {
      return EmbassyPoiPanel(poi: poi, scrollController: scrollController);
    },
    panelPaddingTop: (context) => MediaQuery.of(context).padding.top + 56 - 12 //减去drag的高度
    );

class Embassy extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EmbassyState();
  }
}

class EmbassyState extends State<Embassy> {
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
              Material(
                elevation: 2,
                child: Container(
                  color: Theme.of(context).primaryColor,
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).padding.top + 56,
                  child: Stack(
                    children: <Widget>[
                      Center(
                          child: Text(
                        S.of(context).embassy_guide,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                      )),
                      Align(
                        child: InkWell(
                          onTap: () {
                            BlocProvider.of<DiscoverBloc>(context).add(InitDiscoverEvent());
                          },
                          child: Ink(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              S.of(context).close,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
