import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/business/discover/dmap_define.dart';
import 'package:titan/src/business/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/business/scaffold_map/map.dart';
import 'package:titan/src/consts/consts.dart';

import '../../global.dart';
import 'bloc/bloc.dart';

class DiscoverPageWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DiscoverPageState();
  }
}

class DiscoverPageState extends State<DiscoverPageWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<DiscoverBloc, DiscoverState>(
      listener: (context, state) {
        //listener logic
      },
      bloc: BlocProvider.of<DiscoverBloc>(context),
      child: BlocBuilder<DiscoverBloc, DiscoverState>(
        bloc: BlocProvider.of<DiscoverBloc>(context),
        builder: (context, state) {
          if (state is ActiveDMapState) {
            DMapCreationModel model = DMapDefine.kMapList[state.name];
            if (model != null) {
              return model.createDAppWidgetFunction(context);
            }
          }

          return Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            body: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 260,
                    child: Stack(
                      children: <Widget>[
                        SizedBox(
                          height: 220,
                          child: Carousel(
                            dotVerticalPadding: 16,
                            dotBgColor: Colors.transparent,
                            images: [
                              NetworkImage("https://www.hyn.space/img/header.jpeg"),
                              NetworkImage("https://www.hyn.space/img/header.jpeg"),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              elevation: 10,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text('DMap地图应用接入文档', textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text('文档优化中...',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 24),
                              child: Text(
                                "地图DMap",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                            ),
                            Text('工具类', style: TextStyle(color: Colors.grey)),
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: InkWell(
                                onTap: () async {
                                  activeDMap('encryptShare');
                                  var mapboxController = (Keys.mapKey.currentState as MapContainerState)?.mapboxMapController;
                                  var lastLocation = await mapboxController?.lastKnownLocation();
                                  if(lastLocation != null) {
                                    mapboxController?.animateCamera(CameraUpdate.newLatLngZoom(lastLocation, 17));
                                  }
                                },
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Color(0xFFE9E9E9)),
                                      borderRadius: BorderRadius.all(Radius.circular(4))),
                                  child: Row(
                                    children: <Widget>[
                                      Image.asset('res/drawable/ic_dmap_location_share.png', width: 32, height: 32),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              '私密分享',
                                              style: TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                '分享加密位置，绝不泄露位置信息',
                                                style: TextStyle(color: Colors.grey, fontSize: 13),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: Text('生活指引', style: TextStyle(color: Colors.grey)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: SizedBox(
                                height: 180,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          //全球大使馆
                                          Expanded(
                                            child: InkWell(
                                              borderRadius: BorderRadius.all(Radius.circular(4)),
                                              onTap: () {
                                                activeDMap('embassy');
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                    border: Border.all(color: Color(0xFFE9E9E9)),
                                                    borderRadius: BorderRadius.all(Radius.circular(4))),
                                                child: Row(
                                                  children: <Widget>[
                                                    Image.asset(
                                                      'res/drawable/ic_dmap_mbassy.png',
                                                      width: 32,
                                                      height: 32,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 8.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Text(
                                                            '大使馆指南',
                                                            style: TextStyle(fontWeight: FontWeight.w600),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 8.0),
                                                            child: Text(
                                                              '全球大使馆地图',
                                                              style: TextStyle(color: Colors.grey, fontSize: 13),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          //夜生活指南
                                          Expanded(
                                            child: InkWell(
                                              borderRadius: BorderRadius.all(Radius.circular(4)),
                                              onTap: () {
                                                activeDMap('nightlife');
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                    border: Border.all(color: Color(0xFFE9E9E9)),
                                                    borderRadius: BorderRadius.all(Radius.circular(4))),
                                                child: Row(
                                                  children: <Widget>[
                                                    Image.asset(
                                                      'res/drawable/ic_dmap_bar.png',
                                                      width: 32,
                                                      height: 32,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 8.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Text(
                                                            '夜生活指南',
                                                            style: TextStyle(fontWeight: FontWeight.w600),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 8.0),
                                                            child: Text(
                                                              '夜蒲不再迷路',
                                                              style: TextStyle(color: Colors.grey, fontSize: 13),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
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
                                    //警察服务站
                                    Expanded(
                                      child: InkWell(
                                        borderRadius: BorderRadius.all(Radius.circular(4)),
                                        onTap: () {
                                          activeDMap('policeStation');
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: Color(0xFFE9E9E9)),
                                              borderRadius: BorderRadius.all(Radius.circular(4))),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Image.asset(
                                                'res/drawable/ic_dmap_police.png',
                                                width: 32,
                                                height: 32,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 16.0),
                                                child: Text(
                                                  '警察安全站',
                                                  style: TextStyle(fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  '有困难，找警察',
                                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '更多DMap应用持续添加~',
                                    style: TextStyle(color: Colors.grey, fontSize: 13),
                                  )),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void activeDMap(String dMapName) {
    BlocProvider.of<DiscoverBloc>(context).dispatch(ActiveDMapEvent(name: dMapName));

    var model = DMapDefine.kMapList[dMapName];
    if (model != null) {
      var mapboxController = (Keys.mapKey.currentState as MapContainerState)?.mapboxMapController;
      if(model.dMapConfigModel.defaultLocation != null && model.dMapConfigModel.defaultZoom != null) {
        mapboxController?.animateCamera(CameraUpdate.newLatLngZoom(
          model.dMapConfigModel.defaultLocation,
          model.dMapConfigModel.defaultZoom,
        ));
      }
    }
  }
}
