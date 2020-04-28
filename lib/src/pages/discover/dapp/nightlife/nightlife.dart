import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/data/entity/poi/heaven_map_poi.dart';
import 'package:titan/src/data/entity/poi/poi_interface.dart';
import 'package:titan/src/pages/discover/bloc/bloc.dart';
import 'package:titan/src/components/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/components/scaffold_map/dmap/dmap.dart';
import 'package:titan/src/pages/discover/dapp/nightlife/nightlife_poi_panel.dart';
import 'package:titan/src/utils/map_util.dart';

import 'hot_area.dart';

DMapConfigModel get nightLifeDMapConfigModel {
  return DMapConfigModel(
      dMapName: 'nightlife',
      heavenDataModelList: <HeavenDataModel>[
        HeavenDataModel(
            id: '2c6bfb5fb5714f4f9f42ed01ac486a35',
            sourceLayer: 'heaven',
            sourceUrl: 'https://store.tile.map3.network/maps/global/heaven/{z}/{x}/{y}.vector.pbf',
            color: 0xffEE7AE9)
      ],
      defaultLocation: LatLng(22.296797, 114.170900),
      defaultZoom: 12,
      onMapClickHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
        var poi;
        var feature = await MapUtil.getFeature(point, coordinates, 'layer-heaven-2c6bfb5fb5714f4f9f42ed01ac486a35');
        if (feature != null) {
          poi = HeavenMapPoi.fromMapFeature(feature);
          if (poi != null) {
            BlocProvider.of<ScaffoldMapBloc>(context).add(ShowPoiEvent(poi: poi));
          }
        }
//        if (poi == null) {
//          BlocProvider.of<ScaffoldMapBloc>(context).add(ClearSelectedPoiEvent());
//        }
        return true;
      },
      onMapLongPressHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
        print('on long press nightlife');
        return true;
      },
      panelBuilder: (BuildContext context, ScrollController scrollController, IDMapPoi poi) {
        return NightLifePanel(
          poi: poi,
          scrollController: scrollController,
        );
      },
      panelPaddingTop: (context) => MediaQuery.of(context).padding.top + 56 - 12 //减去drag的高度
      );
}

class NightLife extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NightLifeState();
  }
}

class NightLifeState extends State<NightLife> {
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
                  color: Colors.white,
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).padding.top + 56,
                  child: Stack(
                    children: <Widget>[
                      Center(
                          child: Text(
                        S.of(context).nightlife_guide,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    ],
                  ),
                ),
              ),
            HotArea(),
          ],
        );
      },
    );
  }
}
