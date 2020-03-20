import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/scaffold_map/map.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:connectivity/connectivity.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

class MeCheckIn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeCheckIn();
  }
}

class _MeCheckIn extends State<MeCheckIn> {
  MapboxMapController mapController;

  ScrollController scrollController = ScrollController();

  StreamSubscription subscription;

  LatLng userPosition;
  double defaultZoom = 18;

  StreamController<double> progressStreamController = StreamController.broadcast();

  double minZoom = 18;
  int maxMeter = 30;

  @override
  void initState() {
    super.initState();

    //根据算力计算扫描范围
    if (LOGIN_USER_INFO.totalPower <= 1) {
      minZoom = 17;
      maxMeter = 30;
    } else if (LOGIN_USER_INFO.totalPower <= 10) {
      minZoom = 17;
      maxMeter = 100;
    } else if (LOGIN_USER_INFO.totalPower <= 20) {
      minZoom = 16;
      maxMeter = 500;
    } else if (LOGIN_USER_INFO.totalPower <= 50) {
      minZoom = 15;
      maxMeter = 1200;
    } else if (LOGIN_USER_INFO.totalPower <= 100) {
      minZoom = 14;
      maxMeter = 2000;
    } else if (LOGIN_USER_INFO.totalPower <= 500) {
      minZoom = 13;
      maxMeter = 5000;
    } else {
      minZoom = 12;
      maxMeter = 10000;
    }

    initPosition();

    _checkDeviceType();
  }

  void _checkDeviceType() async {
    if (Platform.isIOS) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile) {
        isVisibleWiFi = false;
        isVisibleToast = true;
      } else if (connectivityResult == ConnectivityResult.wifi) {
        isVisibleWiFi = true;
        isVisibleToast = false;
      }
      print('_checkDevicesType, isIOS');
    } else if (Platform.isAndroid) {
      var isEnable = await TitanPlugin.requestWiFiIsOpenedSetting();
      if (!isEnable) {
        isVisibleWiFi = false;
        isVisibleToast = true;
      } else {
        isVisibleWiFi = true;
        isVisibleToast = false;
      }
      print('_checkDevicesType, isAndroid');
    } else {
      isVisibleWiFi = false;
      isVisibleToast = false;
      print('_checkDevicesType, isOther');
    }
  }

  void initPosition() async {
    userPosition =
        await (Keys.mapContainerKey.currentState as MapContainerState).mapboxMapController?.lastKnownLocation();
  }

  int lastMoveTime = 0;
  int startTime = 0;
  int duration = 30000;
  double lastZoom;
  bool isVisibleWiFi = false;
  bool isVisibleToast = false;
  var _isStartScanning = false;

  void startScan() async {
    if (_isStartScanning) {
      return;
    }

    _isStartScanning = true;
    progressStreamController.add(0);
    duration = max<int>((defaultZoom - minZoom).toInt() * 3000, duration);
    var timeStep = duration / (defaultZoom - minZoom + 1);
    var timerObservable = Observable.periodic(Duration(milliseconds: 500), (x) => x);
    lastZoom = defaultZoom;
    startTime = DateTime.now().millisecondsSinceEpoch;
    if (userPosition != null) {
      mapController.animateCamera(CameraUpdate.newLatLng(userPosition));
    }
    subscription = timerObservable.listen((t) {
      var nowTime = DateTime.now().millisecondsSinceEpoch;
      var timeGap = nowTime - startTime;
      progressStreamController.add(timeGap / duration.toDouble());
      if (timeGap < duration) {
        //scan 30s
        if (nowTime - lastMoveTime > timeStep) {
          mapController.animateCameraWithTime(CameraUpdate.zoomTo(lastZoom--), 1000);
          lastMoveTime = DateTime.now().millisecondsSinceEpoch;
        }
      } else {
        _isStartScanning = false;
        subscription?.cancel();
      }
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    progressStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
//        backgroundColor: Colors.white,
        title: Text(
          S.of(context).map_ai_verificate,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: <Widget>[
          mapView(),
          StreamBuilder<double>(
            stream: progressStreamController.stream,
            builder: (ctx, snap) {
              if (snap?.data != null && snap.data >= 0) {
                return RadarScan();
              }
              return Container();
            },
          ),
          Visibility(
            visible: isVisibleToast,
            child: Positioned(
//              top: 238,
//              left: 100,
//              bottom: 284,
//              right: 109,
              width: 200,
              height: 85,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Image.asset(
                    'res/drawable/wifi_bg.png',
                    fit: BoxFit.contain,
                  ),
                  Positioned(
                    child: Text(
                      S.of(context).turn_on_wifi_hint,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.w500),
                    ),
                    bottom: 15,
                  ),
                  Positioned(
                    right: -27.5,
                    top: 7.5,
                    child: FlatButton(
                      child: Image.asset(
                        'res/drawable/wifi_close.png',
                        height: 12,
                        width: 12,
                        fit: BoxFit.contain,
                      ),
                      onPressed: () {
                        setState(() {
                          isVisibleToast = false;
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          Visibility(
            visible: isVisibleWiFi,
            child: Positioned(
              top: 22,
              right: 21,
              child: Container(
                child: Image.asset(
                  'res/drawable/wifi.png',
                  height: 44,
                  width: 34,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            top: 32,
            left: 16,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    child: Text(
                      S.of(context).all_powers_func('${Utils.powerForShow(LOGIN_USER_INFO.totalPower)}'),
                      style: TextStyle(color: Colors.white),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(color: HexColor("#0F95B0"), borderRadius: BorderRadius.circular(30)),
                  ),
                  Container(
                    child: Text(
                      S.of(context).max_range_func('$maxMeter'),
                      style: TextStyle(color: Colors.white),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    margin: EdgeInsets.only(
                      top: 8,
                    ),
                    decoration: BoxDecoration(color: HexColor("#0F95B0"), borderRadius: BorderRadius.circular(30)),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            child: SizedBox(
              height: 3,
              child: StreamBuilder<double>(
                stream: progressStreamController.stream,
                builder: (ctx, snap) {
                  return LinearProgressIndicator(
                    value: snap?.data ?? 0.0,
                    valueColor: AlwaysStoppedAnimation<Color>(HexColor("#0F95B0")),
                  );
                },
              ),
            ),
            top: 0,
            left: 0,
            right: 0,
          ),
          Positioned(
            bottom: 48,
            child: StreamBuilder<double>(
                stream: progressStreamController.stream,
                builder: (ctx, snap) {
                  return RaisedButton(
                    shape: StadiumBorder(),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Text(
                        (snap?.data == null || snap.data < 1.0) ? S.of(context).background_scan : S.of(context).finish,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget mapView() {
    return MapboxMap(
      compassEnabled: false,
      initialCameraPosition: CameraPosition(
        target: userPosition ?? LatLng(23.12076, 113.322058),
        zoom: defaultZoom,
      ),
      styleString: S.of(context).scan_wifi_map_style_url,
      onMapCreated: (controller) {
        mapController = controller;
      },
      onStyleLoadedCallback: () {
        Future.delayed(Duration(milliseconds: 1000)).then((v) {
          startScan();
        });
      },
      myLocationTrackingMode: MyLocationTrackingMode.None,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      enableLogo: false,
      enableAttribution: false,
//      compassMargins: CompassMargins(left: 0, top: 88, right: 16, bottom: 0),
      minMaxZoomPreference: MinMaxZoomPreference(1.1, 19.0),
      myLocationEnabled: false,
      languageCode: Localizations.localeOf(context).languageCode,
    );
  }
}

class RadarScan extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RadarScanState();
  }
}

class RadarScanState extends State<RadarScan> with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );

    animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: animationController,
        child: Container(
          child: Image.asset(
            'res/drawable/radar_scan.png',
//            height: MediaQuery.of(context).size.height,
//            width: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
        ),
        builder: (BuildContext context, Widget _widget) {
          return Transform.rotate(
            angle: animationController.value * 6.3,
            child: _widget,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
