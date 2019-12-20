import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/src/business/scaffold_map/map.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/plugins/sensor_plugin.dart';

//import 'dart:ffi';
//import 'dart:io';
//import 'package:titan/src/global.dart';
//import 'package:titan/src/utils/utils.dart';
//import 'package:titan/src/plugins/titan_plugin.dart';

class ContributionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ContributionState();
  }
}

class _ContributionState extends State<ContributionPage> {
  MapboxMapController mapController;

  ScrollController scrollController = ScrollController();

  StreamSubscription subscription;

  LatLng userPosition;
  double defaultZoom = 18;

  StreamController<double> progressStreamController = StreamController.broadcast();

  double minZoom = 13;
  int maxMeter = 5000;

  SensorPlugin sensorPlugin;

  @override
  void initState() {
    super.initState();
    sensorPlugin = SensorPlugin();

    /*
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
    */

    initPosition();
  }

  void initPosition() async {
    userPosition =
        await (Keys.mapContainerKey.currentState as MapContainerState).mapboxMapController?.lastKnownLocation();
    await sensorPlugin.init();
  }

  int lastMoveTime = 0;
  int startTime = 0;
  int duration = 30000;
  double lastZoom;
  bool isVisibleWiFi = false;
  bool isVisibleToast = false;
  var _isAcceptSignalProtocol = true;
  var _themeColor = HexColor("#0F95B0");

//  var _themeColor = Theme.of(context).primaryColor;
  var _currentScanType = "WiFi";

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
    sensorPlugin.startScan();
  }

  @override
  void dispose() {
    subscription?.cancel();
    progressStreamController.close();
    super.dispose();
    sensorPlugin.destory();
  }

  String _getImageName() {
    var _imageName = "wifi";

    switch (_currentScanType) {
      case "WiFi":
        _imageName = "wifi";
        break;

      case "基站":
        _imageName = "basestation";
        break;

      case "蓝牙":
        _imageName = "bluetooth";
        break;

      case "GPS":
        _imageName = "gps";
        break;

//      case "磁场":
//        _imageName = "magnetic";
//        break;

//      case "瓦片":
//        _imageName = "tile";
//        break;
    }

    print('[me] --> _imageName:$_imageName');
    return _imageName;
  }

  void _setCurrentScanType(double currentValue) {
    var value = currentValue ?? 0.001;
    if (value > 0 && value < 0.25) {
      _currentScanType = "WiFi";
    } else if (value >= 0.25 && value < 0.5) {
      _currentScanType = "基站";
    } else if (value >= 0.5 && value < 0.75) {
      _currentScanType = "蓝牙";
    } else if (value >= 0.75 && value < 1.0) {
      _currentScanType = "GPS";
    }
    /*else if (value >= 0.8 && value < 0.9) {
      _currentScanType = "磁场";
    } else if (value >= 0.9 && value < 1.0) {
      _currentScanType = "瓦片";
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
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
            top: 21,
            left: 14,
            child: StreamBuilder(
              stream: progressStreamController.stream,
              builder: (ctx, snap) {
                print('[scan] --> value: ${snap.data}');

                var value = snap.data ?? 0.001;
                // todo: 模拟数据
                var angleValue = 360 * value;
                String status = value > 1.0 ? "扫描完成" : "正在扫描中...";
                var signalValue = "信号源:${value}";
                String signalName = '正在$_currentScanType信号扫描';

                // todo: test
                if (value > 1.0) {
                  sensorPlugin.stopScan();
                }

                return Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(
                          status,
                          textAlign: TextAlign.left,
                          style: TextStyle(color: HexColor("#FEFEFE"), fontSize: 14),
                        ),
                        margin: EdgeInsets.only(
                          bottom: 6,
                        ),
                      ),
                      Container(
                        child: Text(
                          signalName,
                          textAlign: TextAlign.left,
                          style: TextStyle(color: HexColor("#FEFEFE"), fontSize: 14),
                        ),
                        margin: EdgeInsets.only(
                          bottom: 6,
                        ),
                      ),
                      Container(
                        child: Text(
                          signalValue,
                          textAlign: TextAlign.left,
                          style: TextStyle(color: HexColor("#FEFEFE"), fontSize: 11),
                        ),
                        margin: EdgeInsets.only(
                          bottom: 6,
                        ),
                      ),
                      Container(
                        child: Text(
                          '强度：$angleValue',
                          textAlign: TextAlign.left,
                          style: TextStyle(color: HexColor("#FEFEFE"), fontSize: 11),
                        ),
                        margin: EdgeInsets.only(
                          bottom: 6,
                        ),
                      ),
                      Container(
                        child: Text(
                          '角度：$angleValue',
                          textAlign: TextAlign.left,
                          style: TextStyle(color: HexColor("#FEFEFE"), fontSize: 11),
                        ),
                        margin: EdgeInsets.only(
                          bottom: 6,
                        ),
                      ),
                      Container(
                        child: Text(
                          '距离：$angleValue',
                          textAlign: TextAlign.left,
                          style: TextStyle(color: HexColor("#FEFEFE"), fontSize: 11),
                        ),
                        margin: EdgeInsets.only(
                          bottom: 6,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 21,
            right: 15,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    child: Text(
                      '最大范围约：$maxMeter 米',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: HexColor("#FEFEFE"), fontSize: 11),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 13),
                    margin: EdgeInsets.only(
                      top: 8,
                    ),
                    decoration: BoxDecoration(color: _themeColor, borderRadius: BorderRadius.circular(30)),
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
                    backgroundColor: _themeColor,
                    value: snap?.data ?? 0.0,
                    valueColor: AlwaysStoppedAnimation<Color>(HexColor("#FFFFFF")),
                  );
                },
              ),
            ),
            top: 0,
            left: 0,
            right: 0,
          ),
          StreamBuilder<double>(
            stream: progressStreamController.stream,
            builder: (ctx, snap) {
              // todo: 模拟数据
              _setCurrentScanType(snap.data);

              return Image.asset(
                'res/drawable/${_getImageName()}_scan.png',
                scale: 2,
              );
            },
          ),

          // todo: 测试
          //..............begin//
//          Positioned(
//            bottom: 188,
//            child: StreamBuilder<double>(
//              stream: progressStreamController.stream,
//              builder: (ctx, snap) {
//                return Image.asset(
//                  'res/drawable/${_getImageName()}_status_scan.png',
//                  scale: 2,
//                );
//              },
//            ),
//          ),
          //..............end//

          Positioned(
            bottom: 48,
            child: StreamBuilder<double>(
              stream: progressStreamController.stream,
              builder: (ctx, snap) {
                if (snap.data < 1.0) {
                  return Container();
                }
                return Column(
                  children: <Widget>[
                    RaisedButton(
                      shape: StadiumBorder(),
                      onPressed: () {
                        Navigator.pop(context);
                      },
//                    color: Theme.of(context).primaryColor,
                      color: HexColor("#CC941E"),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 13),
                        child: Text(
//                          (snap?.data == null || snap.data < 1.0)
//                              ? "后台扫描"
//                              : '确认上传',
                          '确认上传',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    Container(
//                  color: Colors.red,
                        width: 200,
                        height: 40,
                        child: Row(
                          children: <Widget>[
                            Checkbox(
                              value: _isAcceptSignalProtocol,
                              activeColor: _themeColor, //选中时的颜色
                              onChanged: (value) {
                                setState(() {
                                  _isAcceptSignalProtocol = value;
                                });
                              },
                            ),
                            Text(
                              "信号上传协议",
                              style: TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                        )),
                  ],
                );
              },
            ),
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
      styleString: 'https://cn.tile.map3.network/fiord-color.json',
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
