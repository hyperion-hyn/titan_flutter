import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/scaffold_map/map.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'dart:async';

import 'package:titan/src/global.dart';
import 'package:titan/src/utils/utils.dart';

class MeCheckIn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeCheckIn();
  }
}

class _MeCheckIn extends State<MeCheckIn> {
  MapboxMapController mapController;

  ScrollController scrollController = ScrollController();

//  List<String> scanItems = [];
//  List<GaodePoi> pois;
//  int currentPoiIdx = 0;

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
  }

  void initPosition() async {
    userPosition =
        await (Keys.mapContainerKey.currentState as MapContainerState).mapboxMapController?.lastKnownLocation();
//    if (userPosition != null) {
//      var model = await Api().searchByGaode(lat: userPosition.latitude, lon: userPosition.longitude);
//      pois = model.data;
//    }
  }

  int lastMoveTime = 0;
  int startTime = 0;
  int duration = 30000;
  double lastZoom;

  void startScan() async {
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
          "地图AI校验",
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
//            RadarScanWidget(),

          StreamBuilder<double>(
            stream: progressStreamController.stream,
            builder: (ctx, snap) {
              if (snap?.data != null && snap.data >= 0) {
                return RadarScan();
              }
              return Container();
            },
          ),

          Positioned(
            top: 32,
            left: 16,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    child: Text('总算力：${Utils.powerForShow(LOGIN_USER_INFO.totalPower)}', style: TextStyle(color: Colors.white),),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(color: Theme.of(context).accentColor, borderRadius: BorderRadius.circular(30)),
                  ),
                  Container(
                    child: Text('最大范围约：$maxMeter 米', style: TextStyle(color: Colors.white),),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    margin: EdgeInsets.only(top: 8,),
                    decoration: BoxDecoration(color: Theme.of(context).accentColor, borderRadius: BorderRadius.circular(30)),
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
                        (snap?.data == null || snap.data < 1.0) ? "后台扫描" : '完成',
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
      styleString: 'https://static.hyn.space/maptiles/see-it-all.json',
      onStyleLoaded: (mapboxController) {
        mapController = mapboxController;
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
