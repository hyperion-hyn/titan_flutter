import 'dart:async';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/consts/consts.dart';

class NcovMapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NcovMapPageState();
  }
}

class NcovMapPageState extends State<NcovMapPage> {
  MapboxMapController mapboxMapController;
  PublishSubject<dynamic> _toLocationEventSubject = PublishSubject<dynamic>();
  bool myLocationEnabled = false;
  MyLocationTrackingMode locationTrackingMode = MyLocationTrackingMode.None;
  int _clickTimes = 0;
  List<NcovCountLevelModel> levelList= List();

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
      double doubleClickZoom = 7;
      if (latLng != null) {
        if (_clickTimes > 1) {
          mapboxMapController?.animateCameraWithTime(CameraUpdate.newLatLngZoom(latLng, doubleClickZoom), 1200);
        } else if (!trackModeChange) {
          mapboxMapController?.animateCameraWithTime(CameraUpdate.newLatLng(latLng), 700);
        }
      }
      _clickTimes = 0;
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

    var level_6 = NcovCountLevelModel('0', 'ffffff');
    levelList.add(level_6);

    var level_7 = NcovCountLevelModel(S.of(context).suspected, 'fffde7');
    levelList.add(level_7);
  }

  @override
  void dispose() {
    _toLocationEventSubject.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).epidemic_map),
      ),
      body: Stack(
        fit: StackFit.loose,
        children: <Widget>[
          _mapView(), //need a container to expand.
          Positioned(
            bottom: 32,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                _fireToMyLocation();
              },
              mini: true,
              heroTag: 'myLocation',
              backgroundColor: Colors.white,
              child: Icon(
                Icons.my_location,
                color: Colors.black87,
              ),
            ),
          ),
          Positioned(
            bottom: -16,
            left: 16,
            child: Container(
              height: 200,
              width: 250,
              child: ListView.separated(
                physics: new NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(top: 0, bottom: 0),
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
        ],
      ),
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
          SizedBox(width: 16,),
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

  Widget _mapView() {
    return MapboxMap(
      compassEnabled: false,
      initialCameraPosition: CameraPosition(
        target: LatLng(39.919730, 116.399345),
        zoom: 3,
      ),
      styleString: Const.kNcovMapStyleCn,
      onStyleLoaded: onStyleLoaded,
      myLocationEnabled: myLocationEnabled,
      myLocationTrackingMode: locationTrackingMode,
      trackCameraPosition: true,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      enableLogo: false,
      enableAttribution: false,
      minMaxZoomPreference: MinMaxZoomPreference(2, 9.0),
      languageEnable: false,
    );
  }

  void onStyleLoaded(MapboxMapController controller) async {
    setState(() {
      mapboxMapController = controller;

      controller.removeListener(_mapMoveListener);
      controller.addListener(_mapMoveListener);
    });

    Future.delayed(Duration(milliseconds: 500)).then((value) {
      //cheat double click
      _clickTimes = 2;
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

  Widget _showDialogWidget({Widget title, Widget content, List<Widget> actions}) {
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
}

class NcovCountLevelModel {

  String levelTitle = "";
  String hexColor = "";
  NcovCountLevelModel(this.levelTitle, this.hexColor);
}
