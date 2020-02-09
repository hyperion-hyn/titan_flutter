import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/discover/dapp/ncov/bloc/bloc.dart';
import 'package:titan/src/business/infomation/news_nConv_page.dart';
import 'package:titan/src/business/position/model/confirm_poi_item.dart';
import 'package:titan/src/business/scaffold_map/bottom_panels/user_poi_panel.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/drag_tick.dart';
import '../../../../widget/draggable_scrollable_sheet.dart' as myWidget;

import 'package:titan/src/consts/consts.dart';

class NcovMapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NcovMapPageState();
  }
}

class NcovMapPageState extends State<NcovMapPage> with SingleTickerProviderStateMixin {
  NcovBloc _ncovBloc = NcovBloc();
  var picItemWidth;
  MapboxMapController mapboxMapController;
  PublishSubject<dynamic> _toLocationEventSubject = PublishSubject<dynamic>();
  bool myLocationEnabled = false;
  MyLocationTrackingMode locationTrackingMode = MyLocationTrackingMode.None;
  int _clickTimes = 0;
  List<NcovCountLevelModel> levelList = List();

  AnimationController _mapPositionAnimationController;
  final PublishSubject<double> _updateMapPositionSubject = PublishSubject<double>();

  final GlobalKey _poiDraggablePanelKey = GlobalKey(debugLabel: 'nCovPoiDraggablePanelKey');
  final GlobalKey _fabsContainerKey = GlobalKey(debugLabel: 'locationFabsContainerKey');

  @override
  void initState() {
    //to my location
    _toLocationEventSubject.debounceTime(Duration(milliseconds: 500)).listen((_) async {
      bool needUpdate = enableMyLocation(true);
      bool trackModeChange = updateMyLocationTrackingMode(MyLocationTrackingMode.Tracking);
      if (needUpdate || trackModeChange) {
        await Future.delayed(Duration(milliseconds: 300));
      }

      var latLng = await mapboxMapController?.lastKnownLocation();
      double doubleClickZoom = 16;
      if (latLng != null) {
        if (_clickTimes > 1) {
          mapboxMapController?.animateCameraWithTime(CameraUpdate.newLatLngZoom(latLng, doubleClickZoom), 1200);
        } else if (!trackModeChange) {
          mapboxMapController?.animateCameraWithTime(CameraUpdate.newLatLng(latLng), 700);
        }
      }
      _clickTimes = 0;
    });

    _mapPositionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      value: 0,
      vsync: this,
    );

    _updateMapPositionSubject.debounceTime(Duration(milliseconds: 50)).listen((lastValue) {
//      _mapPositionAnimationController.animateTo(lastValue, curve: Curves.linearToEaseOut);
      _mapPositionAnimationController.value = lastValue;
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _setupLevelList();

    super.didChangeDependencies();
  }

  void _setupLevelList() {
    var level_1 = NcovCountLevelModel('> 1000', '7c0000');
    levelList.add(level_1);

    var level_2 = NcovCountLevelModel('500 - 1000', 'd52f30');
    levelList.add(level_2);

    var level_3 = NcovCountLevelModel('100 - 499', 'f3664c');
    levelList.add(level_3);

    var level_4 = NcovCountLevelModel('10 - 99', 'ffa477');
    levelList.add(level_4);

    var level_5 = NcovCountLevelModel('1 - 9', 'ffd5c0');
    levelList.add(level_5);

//    var level_6 = NcovCountLevelModel('0', 'ffffff');
//    levelList.add(level_6);

//    var level_7 = NcovCountLevelModel(S.of(context).suspected, 'fffde7');
//    levelList.add(level_7);
  }

  @override
  void dispose() {
    _ncovBloc.close();
    _updateMapPositionSubject.close();
    _toLocationEventSubject.close();
    _mapPositionAnimationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    picItemWidth = (MediaQuery.of(context).size.width - 15 * 3.0) / 2.6;

    return BlocBuilder<NcovBloc, NcovState>(
        bloc: _ncovBloc,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Color(0xff2B344A),
            appBar: AppBar(
              title: Text(S.of(context).epidemic_map),
              actions: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NewsNcovPage()));
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    alignment: Alignment.centerRight,
                    child: Text(
                      S.of(context).ncov_guide,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
            body: myWidget.DraggableScrollableActuator(
              child: LayoutBuilder(
                builder: (context, BoxConstraints constraints) {
                  return Stack(
                    children: <Widget>[
                      _mapView(constraints), //need a container to expand.
                      _buildNorm(),
                      _buildMyLocation(),

                      RaisedButton(
                        onPressed: () {
                          myWidget.DraggableScrollableActuator.setMin(context);
                        },
                        child: Text(S.of(context).show + " bottom sheet"),
                      ),
                      _buildPanelView(context, constraints),
                    ],
                  );
                },
              ),
            ),
          );
        });
  }

  Widget _buildNorm() {
    return Positioned(
      bottom: 16,
      left: 16,
      child: IgnorePointer(
        child: Container(
          height: 130,
          width: 108,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(4)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: new NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildItem(levelList[index]);
            },
            separatorBuilder: (context, index) {
              return Container(
                height: 6,
              );
            },
            itemCount: levelList.length,
          ),
        ),
      ),
    );
  }

  Widget _buildMyLocation() {
    return LocationWidget(
      onTap: _fireToMyLocation,
      key: _fabsContainerKey,
    );
  }

  Widget _buildItem(NcovCountLevelModel model) {
    return Container(
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 10,
            height: 10,
            child: Container(
              decoration: BoxDecoration(
                color: HexColor(model.hexColor),
                border: Border.all(color: HexColor(model.hexColor)),
                borderRadius: BorderRadius.all(Radius.circular(2)),
                boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 0.25)],
              ),
            ),
          ),
          SizedBox(
            width: 16,
          ),
          Text(
            model.levelTitle,
            textAlign: TextAlign.left,
            style: TextStyle(color: HexColor("#000000"), fontSize: 12),
          ),
        ],
      ),
      margin: EdgeInsets.only(
        bottom: 4,
      ),
    );
  }

  Widget _mapView(BoxConstraints constraints) {
    double minSize = 0.50 * constraints.biggest.height;
    var expandedRelative = RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0);
    var topRelative = RelativeRect.fromLTRB(0.0, -minSize, 0.0, minSize);
    final Animation<RelativeRect> panelAnimation = _mapPositionAnimationController.drive(
      RelativeRectTween(
        begin: expandedRelative,
        end: topRelative,
      ),
    );

    return Stack(
      children: <Widget>[
        PositionedTransition(
          rect: panelAnimation,
          child: MapboxMap(
            compassEnabled: false,
            initialCameraPosition: CameraPosition(
              target: LatLng(39.919730, 116.399345),
              zoom: 7,
            ),
            styleString: "https://cn.tile.map3.network/ncov_test.json",
//            styleString: Const.kNcovMapStyleCn,
            onStyleLoaded: onStyleLoaded,
            myLocationEnabled: myLocationEnabled,
            myLocationTrackingMode: locationTrackingMode,
            trackCameraPosition: true,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            enableLogo: false,
            enableAttribution: false,
            minMaxZoomPreference: MinMaxZoomPreference(1.1, 18.0),
            languageEnable: false,
            onMapClick: (point, coordinates) {
              _onMapClick(point, coordinates);
            },
          ),
        ),
      ],
    );
    /*return MapContainer(
      key: GlobalKey(debugLabel: '__mapffa__'),
      style: Const.kNcovMapStyleCn,
      showCenterMarker: false,
    );*/
  }

  void _onMapClick(Point<double> point, LatLng coordinates) async {
    /*if (widget.mapClickHandle != null) {
      if (await widget.mapClickHandle(context, point, coordinates)) {
        return;
      }
    }*/

    var range = 10;
    Rect rect = Rect.fromLTRB(point.x - range, point.y - range, point.x + range, point.y + range);
    /*if (await _clickOnMarkerLayer(rect)) {
      updateMyLocationTrackingMode(MyLocationTrackingMode.None);
      return;
    }*/
    if (await _clickOnCommonSymbolLayer(rect)) {
      updateMyLocationTrackingMode(MyLocationTrackingMode.None);
      return;
    }

    //if click nothing on the map
//    if (this.currentPoi != null) {
//      BlocProvider.of<ScaffoldMapBloc>(context).add(ClearSelectPoiEvent());
//    }
  }

  Future<bool> _clickOnCommonSymbolLayer(Rect rect) async {
    String filter;
    if (Platform.isAndroid) {
      filter = '["has", "name"]';
    }
    if (Platform.isIOS) {
      filter = "name != NIL";
    }
    List features = await mapboxMapController?.queryRenderedFeaturesInRect(rect, [], filter);

    print("query features :$features");
    var filterFeatureList = features.where((featureString) {
      var feature = json.decode(featureString);

      var type = feature["geometry"]["type"];
      if (type == "Point") {
        return true;
      } else {
        return false;
      }
    }).toList();

    print("filter features :$filterFeatureList");
    if (filterFeatureList != null && filterFeatureList.isNotEmpty) {
      var firstFeature = json.decode(filterFeatureList[0]);
      var coordinatesArray = firstFeature["geometry"]["coordinates"];
      var coordinates = LatLng(coordinatesArray[1], coordinatesArray[0]);
      print("coordinates:$coordinates");
      var languageCode = Localizations.localeOf(context).languageCode;
      var name = "";
      if (languageCode == "zh") {
        name = firstFeature["properties"]["name:zh"];
        if (name == null) {
          name = firstFeature["properties"]["name"];
        }
      } else {
        name = firstFeature["properties"]["name"];
      }

      //the same poi
      /*if (currentPoi?.latLng == coordinates) {
        print('click the same poi');
        return true;
      }

      var pid = firstFeature["properties"]["pid"];
      if (pid != null) {
        var l = position_model.Location.fromJson(firstFeature['geometry']);
        print('xxx33 $l $firstFeature');
        ConfirmPoiItem confirmPoiItem = ConfirmPoiItem.setPid(pid, l);
        BlocProvider.of<ScaffoldMapBloc>(context).add(SearchPoiEvent(poi: confirmPoiItem));
      } else {
        var poi = PoiEntity(name: name, latLng: coordinates);
        BlocProvider.of<ScaffoldMapBloc>(context).add(SearchPoiEvent(poi: poi));
      }*/

      return true;
    } else {
      return false;
    }
  }

  void onStyleLoaded(MapboxMapController controller) async {
    setState(() {
      mapboxMapController = controller;

      controller.removeListener(_mapMoveListener);
      controller.addListener(_mapMoveListener);
    });

    Future.delayed(Duration(milliseconds: 500)).then((value) {
      //cheat double click
//      _clickTimes = 2;
      _fireToMyLocation();
    });
  }

  bool updateMyLocationTrackingMode(MyLocationTrackingMode mode) {
    if (mode != locationTrackingMode) {
      setState(() {
        locationTrackingMode = mode;
      });
      return true;
    }
    return false;
  }

  bool enableMyLocation(bool enable) {
    if (myLocationEnabled != enable) {
      setState(() {
        myLocationEnabled = enable;
      });
      return true;
    }
    return false;
  }

  Future _toMyLocationSink() async {
    _clickTimes++;
    _toLocationEventSubject.sink.add(1);
  }

  void _mapMoveListener() {
    //change tracking mode to none if user drag the map
    if (mapboxMapController?.isGesture == true) {
      updateMyLocationTrackingMode(MyLocationTrackingMode.None);
    }
  }

  void _fireToMyLocation() async {
    ServiceStatus serviceStatus = await PermissionHandler().checkServiceStatus(PermissionGroup.location);

    if (serviceStatus == ServiceStatus.disabled) {
      _showGoToOpenLocationServceDialog();
      return;
    }

    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.location);
    if (permission == PermissionStatus.granted) {
      _toMyLocationSink();
    } else {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler().requestPermissions([PermissionGroup.location]);
      if (permissions[PermissionGroup.location] == PermissionStatus.granted) {
        _toMyLocationSink();
        Observable.timer('', Duration(milliseconds: 1500)).listen((d) {
          _toMyLocationSink(); //hack, location not auto move
        });
      } else {
        _showGoToOpenAppSettingsDialog();
      }
    }
  }

  void _showGoToOpenAppSettingsDialog() {
    _showDialogWidget(
        title: Text(S.of(context).require_location),
        content: Text(S.of(context).require_location_message),
        actions: <Widget>[
          FlatButton(
            child: Text(S.of(context).cancel),
            onPressed: () => Navigator.pop(context),
          ),
          FlatButton(
            child: Text(S.of(context).setting),
            onPressed: () {
              PermissionHandler().openAppSettings();
              Navigator.pop(context);
            },
          ),
        ]);
  }

  void _showGoToOpenLocationServceDialog() {
    _showDialogWidget(
      title: Text(S.of(context).open_location_service),
      content: Text(S.of(context).open_location_service_message),
      actions: <Widget>[
        FlatButton(
          child: Text(S.of(context).cancel),
          onPressed: () => Navigator.pop(context),
        ),
        FlatButton(
          child: Text(S.of(context).setting),
          onPressed: () {
            if (Platform.isIOS) {
              PermissionHandler().openAppSettings();
            } else {
              AndroidIntent intent = new AndroidIntent(
                action: 'action_location_source_settings',
              );
              intent.launch();
            }
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _showDialogWidget({Widget title, Widget content, List<Widget> actions}) {
    showDialog(
      context: context,
      builder: (context) {
        return Platform.isIOS
            ? CupertinoAlertDialog(
                title: title,
                content: content,
                actions: actions,
              )
            : AlertDialog(
                title: title,
                content: content,
                actions: actions,
              );
      },
    );
  }

  Widget _buildPanelView(BuildContext context, BoxConstraints constraints) {
    return NotificationListener<myWidget.DraggableScrollableNotification>(
      onNotification: (notification) {
        if (notification.extent <= notification.anchorExtent) {
//          print('xxx ${notification.extent}');
//          _mapPositionAnimationController.value = notification.extent;
          _updateMapPositionSubject.sink.add(notification.extent);
        }
        var maxHeight = constraints.biggest.height;
        updateFabsPosition(notification.extent * maxHeight, notification.anchorExtent * maxHeight);
        return false;
      },
      child: myWidget.DraggableScrollableSheet(
        key: _poiDraggablePanelKey,
        maxChildSize: 1.0,
        anchorSize: 0.66,
        minChildSize: 0.3,
        initialChildSize: 0.3,
        draggable: true,
        expand: true,
        builder: (BuildContext ctx, ScrollController scrollController) {
          //TODO 设置选中POI的panel view
          return Container(
            padding: const EdgeInsets.only(top: 4),
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
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: DragTick(),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () {
                            myWidget.DraggableScrollableActuator.setHide(context);
                            _updateMapPositionSubject.sink.add(0);
                            updateFabsPosition(0, constraints.biggest.height);
//                                            BlocProvider.of<ScaffoldMapBloc>(context).add(ClearSelectPoiEvent());
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10.0, top: 6),
                            child: Icon(
                              Icons.cancel,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      "hello, this is demo",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left:16.0,bottom: 5),
                    child: buildHeadItem(context,
                        Icons.location_on, "小区地址",
                        hint: S.of(context).no_detail_address),
                  ),
                  // Todo: 测试数据
                  Divider(
                    height: 0,
                  ),
//                                      if (widget.selectedPoiEntity.images != null &&
//                                          widget.selectedPoiEntity.images.length > 0)
                                      buildPicList(picItemWidth, 16, ['http://a4.att.hudong.com/03/25/20300001045622130690259454464.jpg',
                                        'http://a4.att.hudong.com/03/25/20300001045622130690259454464.jpg',
                                        'http://a4.att.hudong.com/03/25/20300001045622130690259454464.jpg',
                                        'http://a4.att.hudong.com/03/25/20300001045622130690259454464.jpg',
                                        'http://a4.att.hudong.com/03/25/20300001045622130690259454464.jpg',
                                        'http://a4.att.hudong.com/03/25/20300001045622130690259454464.jpg',]),

                  _buildInfoItem(S.of(context).ncov_cell_title_numbers + "：", "1"),
                  _buildInfoItem(S.of(context).ncov_cell_title_category + "：", "本地人"),
                  _buildInfoItem(S.of(context).ncov_cell_title_isolation + "：", "是"),
                  _buildInfoItem(S.of(context).ncov_cell_title_property + "：", "租住"),
                  _buildInfoItem(S.of(context).ncov_cell_title_symptoms + "：", "发热、腹泻、浑身乏力"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8.0),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: TextStyles.textC777S14,
          ),
          Expanded(
              child: Text(
            content,
            style: TextStyles.textC333S14,
          ))
        ],
      ),
    );
  }

  void updateFabsPosition(double bottom, double anchorHeight) {
    var state = (_fabsContainerKey.currentState is LocationWidgetState)
        ? _fabsContainerKey.currentState as LocationWidgetState
        : null;
    WidgetsBinding.instance.addPostFrameCallback((_) => state?.updateBottomPadding(bottom, anchorHeight));
  }
}

class LocationWidget extends StatefulWidget {
  final Function onTap;

  LocationWidget({this.onTap, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LocationWidgetState();
  }
}

class LocationWidgetState extends State<LocationWidget> {
  double _fabsBottom = 16;
  double _opacity = 1;

  void updateBottomPadding(double bottom, double anchorHeight) {
    if (bottom >= 0 && bottom <= anchorHeight) {
      setState(() {
        _fabsBottom = bottom;
        _opacity = 1;
      });
    }
    if (bottom > anchorHeight) {
      double dy = _fabsBottom + 50 - bottom;
      if (dy > 0) {
        setState(() {
          _opacity = dy / 50;
        });
      } else if (_opacity != 0) {
        setState(() {
          _opacity = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: _fabsBottom + 16,
      right: 16,
      child: IgnorePointer(
        ignoring: _opacity == 0,
        child: Opacity(
          opacity: _opacity,
          child: FloatingActionButton(
            onPressed: widget.onTap,
            mini: true,
            heroTag: 'myLocation',
            backgroundColor: Colors.white,
            child: Icon(
              Icons.my_location,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class NcovCountLevelModel {
  String levelTitle = "";
  String hexColor = "";

  NcovCountLevelModel(this.levelTitle, this.hexColor);
}
