import 'dart:convert';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/discover/dmap_define.dart';
import 'package:titan/src/business/infomation/model/focus_response.dart';
import 'package:titan/src/business/scaffold_map/map.dart';
import 'package:titan/src/business/webview/webview.dart';
import 'package:titan/src/consts/consts.dart';

import 'bloc/bloc.dart';

class DiscoverPageWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DiscoverPageState();
  }
}

class DiscoverPageState extends State<DiscoverPageWidget> {
  List<FocusImage> focusImages = [FocusImage('res/drawable/discover_first_image.jpeg', "https://www.hyn.space")];

  @override
  void initState() {
    super.initState();

    loadCacheData();

    BlocProvider.of<DiscoverBloc>(context).add(LoadFocusImageEvent());
  }

  void loadCacheData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ss1 = prefs.getString("disc_focus");
    if (ss1 != null) {
      var flist = (jsonDecode(ss1) as List<dynamic>).map((element) => FocusImage.fromJson(element)).toList();
      if (flist != null && flist.isNotEmpty) {
        focusImages = flist;

        if (mounted) {
          setState(() {});
        }
      }
    }
  }

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
          } else if (state is LoadedFocusState) {
            focusImages = state.focusImages;
          }
          return Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            body: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 290,
                    child: Stack(
                      children: <Widget>[
                        SizedBox(
                          height: 220,
                          child: Carousel(
                            borderRadius: true,
                            radius: Radius.circular(0),
                            onImageTap: (int index) {
                              var focusImage = focusImages[index];

                              print(focusImage.toString());
                              if (focusImage.link == null || focusImage.link.isEmpty) {
                                return;
                              }

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WebViewContainer(
                                            initUrl: focusImage.link,
                                            title: "",
                                          )));
                            },
                            dotVerticalPadding: 16,
                            dotBgColor: Colors.transparent,
                            images: focusImages.map((focusImage) {
                              return FadeInImage.assetNetwork(
                                placeholder: 'res/drawable/img_placeholder.jpg',
                                image: focusImage.cover,
                                fit: BoxFit.cover,
                              );
                            }).toList(),
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
                                    Text(S.of(context).dmap_document_title,
                                        textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(S.of(context).document_optimization,
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
                                S.of(context).map_dmap,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                            ),
                            Text(S.of(context).dmap_tools, style: TextStyle(color: Colors.grey)),
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: InkWell(
                                onTap: () async {
                                  activeDMap('encryptShare');
                                  var mapboxController =
                                      (Keys.mapContainerKey.currentState as MapContainerState)?.mapboxMapController;

                                  var lastLocation = await mapboxController?.lastKnownLocation();
                                  if (lastLocation != null) {
                                    Future.delayed(Duration(milliseconds: 500)).then((value) {
                                      mapboxController?.animateCamera(CameraUpdate.newLatLngZoom(lastLocation, 17));
                                    });
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
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                S.of(context).private_sharing,
                                                style: TextStyle(fontWeight: FontWeight.w600),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  S.of(context).private_sharing_text,
                                                  style: TextStyle(color: Colors.grey, fontSize: 13),
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
                            Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: Text(S.of(context).dmap_life, style: TextStyle(color: Colors.grey)),
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
                                                      width: 28,
                                                      height: 28,
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(left: 8.0),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Text(
                                                              S.of(context).embassy_guide,
                                                              style: TextStyle(fontWeight: FontWeight.w600),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(top: 8.0),
                                                              child: Row(
                                                                children: <Widget>[
                                                                  Expanded(
                                                                    child: Text(
                                                                      S.of(context).global_embassies,
                                                                      style:
                                                                          TextStyle(color: Colors.grey, fontSize: 13),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
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
//                                                activeDMap('nightlife');
                                                Fluttertoast.showToast(msg: S.of(context).stay_tuned);
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
                                                      width: 28,
                                                      height: 28,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 8.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Text(
                                                            S.of(context).discount_map,
                                                            style: TextStyle(fontWeight: FontWeight.w600),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 8.0),
                                                            child: Text(
                                                              S.of(context).not_open_yet,
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
                                                  S.of(context).police_security_station,
                                                  style: TextStyle(fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  S.of(context).police_station_text,
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
                                    S.of(context).more_dmap,
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

  void activeDMap(String dMapName) async {
    BlocProvider.of<DiscoverBloc>(context).add(ActiveDMapEvent(name: dMapName));

    var model = DMapDefine.kMapList[dMapName];
    if (model != null) {
      var mapboxController = (Keys.mapContainerKey.currentState as MapContainerState)?.mapboxMapController;
      await mapboxController?.disableLocation();

      if (model.dMapConfigModel.defaultLocation != null && model.dMapConfigModel.defaultZoom != null) {
        Future.delayed(Duration(milliseconds: 500)).then((value) {
          mapboxController?.animateCamera(CameraUpdate.newLatLngZoom(
            model.dMapConfigModel.defaultLocation,
            model.dMapConfigModel.defaultZoom,
          ));
        });
      }
    }
  }
}
