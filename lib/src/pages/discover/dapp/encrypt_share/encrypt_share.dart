import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/scaffold_map/dmap/dmap.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/discover/bloc/bloc.dart';
import 'package:titan/src/pages/discover/dapp/encrypt_share/share_dialog.dart';
import 'package:titan/src/components/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/data/entity/poi/poi_interface.dart';
import 'package:titan/src/pages/discover/dapp/encrypt_share/share_pois_panel.dart';

import 'event.dart';

final encryptShareDMapConfigModel = DMapConfigModel(
  dMapName: 'encryptShare',
  onMapClickHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
    print('on click encrypt share');
    return true;
  },
  onMapLongPressHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
    print('on long press encrypt share');
    return true;
  },
  alwaysShowPanel: true,
  panelDraggable: true,
  showCenterMarker: true,
  panelBuilder: (BuildContext context, ScrollController scrollController, IDMapPoi poi) {
    return SharePoisPanel(scrollController: scrollController);
  },
  panelPaddingTop: (context) => MediaQuery.of(context).size.height * 0.45,
  panelAnchorHeight: (context) => MediaQuery.of(context).size.height * 0.55,
  panelCollapsedHeight: (context) => 220,
);

class EncryptShare extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EncryptShareState();
  }
}

class EncryptShareState extends State<EncryptShare> {
  IPoi selectedPoi;

  StreamSubscription streamSubscription;

  @override
  void initState() {
    super.initState();

//    //动态设置收缩高度
//    SchedulerBinding.instance.addPostFrameCallback((_) {
//      HeaderHeightNotification(height: 400).add(context);
//    });

    streamSubscription = Application.eventBus.on().listen(eventBusListener);
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  void eventBusListener(event) async {
    if (event is SelectedSharePoiEvent) {
      selectedPoi = event.poi;
    }
  }

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
                color: Colors.transparent,
                child: Container(
//                  decoration: BoxDecoration(
//                    gradient: new LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
//                      Colors.black38,
//                      Colors.transparent,
//                    ]),
//                  ),
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).padding.top + 100,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Stack(
                      children: <Widget>[
                        Align(
                          child: InkWell(
                            onTap: () {
                              BlocProvider.of<DiscoverBloc>(context).add(InitDiscoverEvent());
                            },
                            child: Ink(
                              padding: const EdgeInsets.only(left: 24.0, top: 8),
                              child: Text(
                                S.of(context).close,
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          alignment: Alignment.topLeft,
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: InkWell(
                              onTap: () async {
                                print('-你将要加密 $selectedPoi');
                                if (selectedPoi != null) {
                                  var suc = await showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return ShareDialog(poi: selectedPoi);
                                      });
                                  //成功打开分享
                                  if (suc) {
                                    //关闭分享位置
//                                    BlocProvider.of<DiscoverBloc>(context).add(InitDiscoverEvent());
                                    print('-成功打开分享');
                                  }
                                }
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.all(Radius.circular(4))),
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                child: Text(
                                  S.of(context).start_encryption,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
