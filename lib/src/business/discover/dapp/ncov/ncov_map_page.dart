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
import 'package:titan/src/business/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/consts/consts.dart';
import '../../../../global.dart';

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
  StreamSubscription _eventBusSubscription;

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
      double doubleClickZoom = 6;
      if (latLng != null) {
        if (_clickTimes > 0) {
          mapboxMapController?.animateCameraWithTime(CameraUpdate.newLatLngZoom(latLng, doubleClickZoom), 1200);
        } else if (!trackModeChange) {
          mapboxMapController?.animateCameraWithTime(CameraUpdate.newLatLng(latLng), 700);
        }
      }
      _clickTimes = 0;
    });

    _listenEventBus();

    Future.delayed(Duration(milliseconds: 2000)).then((value) {
      eventBus.fire(ToMyLocationEvent());
    });

    super.initState();
  }

  @override
  void dispose() {
    _toLocationEventSubject.close();
    _eventBusSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: <Widget>[
        _mapView(), //need a container to expand.
        //top bar
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
                  S.of(context).epidemic_map,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                )),
                Align(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
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
  }

  Widget _mapView() {
    return MapboxMap(
      compassEnabled: false,
      initialCameraPosition: CameraPosition(
        target: recentlyLocation,
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
      minMaxZoomPreference: MinMaxZoomPreference(1.1, 7.0),
      languageEnable: false,
    );
  }

  void onStyleLoaded(MapboxMapController controller) async {
    setState(() {
      mapboxMapController = controller;

      controller.removeListener(_mapMoveListener);
      controller.addListener(_mapMoveListener);
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

  Future _toMyLocation() async {
    _clickTimes++;
    _toLocationEventSubject.sink.add(1);
  }

  void _mapMoveListener() {
    //change tracking mode to none if user drag the map
    if (mapboxMapController?.isGesture == true) {
      updateMyLocationTrackingMode(MyLocationTrackingMode.None);
    }
  }

  void _listenEventBus() {
    _eventBusSubscription = eventBus.on().listen((event) async {
//      print('[ncov] -->o');

      if (event is ToMyLocationEvent) {
        //check location service

        ServiceStatus serviceStatus = await PermissionHandler().checkServiceStatus(PermissionGroup.location);

        if (serviceStatus == ServiceStatus.disabled) {
          _showGoToOpenLocationServceDialog();
          return;
        }

        PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.location);
        if (permission == PermissionStatus.granted) {
          _toMyLocation();
        } else {
          Map<PermissionGroup, PermissionStatus> permissions =
              await PermissionHandler().requestPermissions([PermissionGroup.location]);
          if (permissions[PermissionGroup.location] == PermissionStatus.granted) {
            _toMyLocation();
            Observable.timer('', Duration(milliseconds: 1500)).listen((d) {
              _toMyLocation(); //hack, location not auto move
            });
          } else {
            _showGoToOpenAppSettingsDialog();
          }
        }
      }
    });
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
